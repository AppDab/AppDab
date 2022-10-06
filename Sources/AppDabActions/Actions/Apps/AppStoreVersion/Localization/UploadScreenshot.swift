import Bagbutik_AppStore
import Bagbutik_Models
import CryptoKit
import Foundation

/**
 Upload a screenshot to a `AppScreenshotSet`.

 This action loads the screenshot at the specified file URL, reserves space for the screenshot, uploads it
 and tells the App Store Connect API, that the upload is complete.
 The validation of the screenshot happens on Apple's servers.

 - Parameters:
    - screenshotSetId: The id of the `AppScreenshotSet` the screenshot should be related to.
    - screenshotFileURL: The file URL for the screenshot to upload.
    - didCreateScreenshotReservation: A callback for when space for the screenshot has been reserved.
    - progressChanged: A callback for when the actual upload of the screenshot happens.
 - Returns: The uploaded `AppScreenshot`.
 */
@discardableResult
public func uploadScreenshot(toScreenshotSetWithId screenshotSetId: String,
                             screenshotFileURL: URL,
                             didCreateScreenshotReservation: (AppScreenshot, _ totalSize: Int) -> Void,
                             progressChanged: (_ id: String, _ value: Int, _ totalSize: Int) -> Void) async throws -> AppScreenshot {
    ActionsEnvironment.logger.info("🔍 Reading screenshot at \(screenshotFileURL.path)...")
    let screenshotData = try Data(contentsOf: screenshotFileURL)
    let totalSize = screenshotData.count
    let byteCountFormatter = ByteCountFormatter()
    byteCountFormatter.includesActualByteCount = true
    ActionsEnvironment.logger.info("👍 Read screnshot. Size \(byteCountFormatter.string(from: .init(value: Double(totalSize), unit: .bytes)))")
    ActionsEnvironment.logger.info("🚀 Reserving space for screenshot...")
    let reserveResponse = try await ActionsEnvironment.service.request(
        .createAppScreenshotV1(requestBody: .init(data: .init(
            attributes: .init(fileName: "AppDab-screenshot-\(UUID().uuidString).png", fileSize: totalSize),
            relationships: .init(appScreenshotSet: .init(data: .init(id: screenshotSetId)))
        )))
    )
    ActionsEnvironment.logger.info("👍 Space for screenshot reserved")
    didCreateScreenshotReservation(reserveResponse.data, totalSize)
    try await withThrowingTaskGroup(of: Int.self, body: { taskGroup in
        ActionsEnvironment.logger.info("🚀 Uploading screenshot data...")
        reserveResponse.data.attributes?.uploadOperations?
            .forEach { uploadOperation in
                let subdata = screenshotData.subdata(in: .init(uncheckedBounds:
                    (lower: uploadOperation.offset!, upper: uploadOperation.offset! + uploadOperation.length!)
                ))
                let uploadOperationInfo = UploadOperationInfo(
                    url: URL(string: uploadOperation.url!)!,
                    method: uploadOperation.method!,
                    headers: uploadOperation.requestHeaders!.reduce(into: [:]) { partialResult, header in
                        partialResult[header.name!] = header.value!
                    },
                    data: subdata
                )
                taskGroup.addTask {
                    var urlRequest = URLRequest(url: uploadOperationInfo.url)
                    urlRequest.httpMethod = uploadOperationInfo.method
                    uploadOperationInfo.headers.forEach { headerName, headerValue in
                        urlRequest.addValue(headerValue, forHTTPHeaderField: headerName)
                    }
                    _ = try await ActionsEnvironment.uploadData(urlRequest, uploadOperationInfo.data, nil)
                    return uploadOperationInfo.data.count
                }
            }
        var totalBytesUploaded = 0
        for try await bytesUploaded in taskGroup {
            totalBytesUploaded += bytesUploaded
            let totalBytesUploadedString = byteCountFormatter.string(from: .init(value: Double(totalBytesUploaded), unit: .bytes))
            let totalSizeString = byteCountFormatter.string(from: .init(value: Double(totalSize), unit: .bytes))
            ActionsEnvironment.logger.info("• \(totalBytesUploadedString) of \(totalSizeString)")
            progressChanged(reserveResponse.data.id, totalBytesUploaded, totalSize)
        }
    })
    let md5Hash = Insecure.MD5
        .hash(data: screenshotData)
        .map { String(format: "%02x", $0) }
        .joined()
    ActionsEnvironment.logger.info("🚀 Committing screenshot...")
    let commitResponse = try await ActionsEnvironment.service.request(.updateAppScreenshotV1(
        id: reserveResponse.data.id,
        requestBody: .init(data: .init(
            id: reserveResponse.data.id,
            attributes: .init(sourceFileChecksum: md5Hash, uploaded: true)
        ))
    ))
    ActionsEnvironment.logger.info("👍 Screenshot uploaded and will now be processed")
    return commitResponse.data
}

private struct UploadOperationInfo: @unchecked Sendable {
    let url: URL
    let method: String
    let headers: [String: String]
    let data: Data
}
