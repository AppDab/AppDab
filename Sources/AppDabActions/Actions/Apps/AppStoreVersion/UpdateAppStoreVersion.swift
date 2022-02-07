import Bagbutik
import Foundation

@discardableResult
public func updateAppStoreVersion(forAppStoreVersionId appStoreVersionId: String,
                                  version: String? = nil,
                                  copyright: String? = nil) async throws -> AppStoreVersion {
    guard version != nil || copyright != nil else {
        throw AppStoreVersionError.noNewValuesSpecified
    }
    var attributes = AppStoreVersionUpdateRequest.Data.Attributes()
    var logValues = [String]()
    if let version = version {
        attributes.versionString = version
        logValues.append("version '\(version)'")
    }
    if let copyright = copyright {
        attributes.copyright = copyright
        logValues.append("copyright '\(copyright)'")
    }
    let requestBody = AppStoreVersionUpdateRequest(data: .init(id: appStoreVersionId, attributes: attributes))
    ActionsEnvironment.logger.info("🚀 Updating App Store version with id '\(appStoreVersionId)' with \(ListFormatter.localizedString(byJoining: logValues))...")
    let appStoreVersionResponse = try await ActionsEnvironment.service.request(
        .updateAppStoreVersion(id: appStoreVersionId, requestBody: requestBody))
    ActionsEnvironment.logger.info("👍 App Store version updated")
    return appStoreVersionResponse.data
}
