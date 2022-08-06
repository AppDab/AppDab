import AppDabActions
import Bagbutik_Models
import XCTest

final class UploadScreenshotTests: ActionsTestCase {
    func testUploadScreenshot() async {
        let id = "some-id"
        let reserveResponse = AppScreenshotResponse(
            data: .init(id: id, links: .init(self: ""), attributes: .init(uploadOperations: [
                .init(length: 2000000, method: "PUT", offset: 0, requestHeaders: [.init(name: "content-type", value: "image/png")], url: "https://url-1.com"),
                .init(length: 770139, method: "PUT", offset: 2000000, requestHeaders: [.init(name: "content-type", value: "image/png")], url: "https://url-2.com"),
            ])),
            links: .init(self: "")
        )
        mockBagbutikService.setResponse(reserveResponse, for: Endpoint(path: "/v1/appScreenshots", method: .post))
        reserveResponse.data.attributes!.uploadOperations?.forEach { uploadOperation in
            let url = URL(string: uploadOperation.url!)!
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
            let delay = uploadOperation.offset ?? 0 > 0 ? 1 : 0
            mockURLSession.uploadResult[url] = (data: Data(), response: response, delay: delay)
        }
        let commitResponse = AppScreenshotResponse(
            data: .init(id: id, links: .init(self: ""), attributes: .init(
                assetDeliveryState: .init(errors: [], state: .uploadComplete, warnings: [])
            )),
            links: .init(self: "")
        )
        mockBagbutikService.setResponse(commitResponse, for: Endpoint(path: "/v1/appScreenshots/\(id)", method: .patch))
        let screenshotFileURL = Bundle.module.url(forResource: "screenshot1", withExtension: "png")!
        let didCreateExpectation = XCTestExpectation(description: "didCreate")
        let progressChangedExpectation = XCTestExpectation(description: "progressChanged")
        progressChangedExpectation.expectedFulfillmentCount = 2
        var numberOfProgressChangedCalls = [Int]()
        let screenshot = try! await uploadScreenshot(toScreenshotSetWithId: "set-id", screenshotFileURL: screenshotFileURL, didCreateScreenshotReservation: { screnshot, totalSize in
            XCTAssertEqual(screnshot.id, id)
            XCTAssertEqual(totalSize, 2770139)
            didCreateExpectation.fulfill()
        }, progressChanged: { screenshotId, value, totalSize in
            XCTAssertEqual(screenshotId, id)
            numberOfProgressChangedCalls.append(value)
            XCTAssertEqual(totalSize, 2770139)
            progressChangedExpectation.fulfill()
        })
        XCTAssertEqual(screenshot, commitResponse.data)
        let byteCountFormatter = ByteCountFormatter()
        byteCountFormatter.includesActualByteCount = true
        let twoMegaBytesFormatted = byteCountFormatter.string(from: .init(value: 2000000, unit: .bytes))
        let totalSizeFormatted = byteCountFormatter.string(from: .init(value: 2770139, unit: .bytes))
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "🔍 Reading screenshot at \(screenshotFileURL.path)..."),
            Log(level: .info, message: "👍 Read screnshot. Size \(totalSizeFormatted)"),
            Log(level: .info, message: "🚀 Reserving space for screenshot..."),
            Log(level: .info, message: "👍 Space for screenshot reserved"),
            Log(level: .info, message: "🚀 Uploading screenshot data..."),
            Log(level: .info, message: "• \(twoMegaBytesFormatted) of \(totalSizeFormatted)"),
            Log(level: .info, message: "• \(totalSizeFormatted) of \(totalSizeFormatted)"),
            Log(level: .info, message: "🚀 Committing screenshot..."),
            Log(level: .info, message: "👍 Screenshot uploaded and will now be processed"),
        ])
        wait(for: [didCreateExpectation, progressChangedExpectation], timeout: 1)
        XCTAssertEqual(numberOfProgressChangedCalls.sorted(), [2000000, 2770139])
    }
}

extension AppScreenshot: Equatable {
    public static func == (lhs: AppScreenshot, rhs: AppScreenshot) -> Bool {
        lhs.id == rhs.id
    }
}
