import Bagbutik
import Foundation

/**
 Update an App Store version.

 An App Store version is the differnet versions available (or going to be available) in the App Store.
 The info on an App Store version is the non-localizable parts.

 - Parameters:
    - id: The id of the `AppStoreVersion` to be updated.
    - newVersion: The new version.
    - newCopyright: The new copyright.
 - Returns: The updated `AppStoreVersion`.
 */
@discardableResult
public func updateAppStoreVersion(withId id: String,
                                  newVersion: String? = nil,
                                  newCopyright: String? = nil) async throws -> AppStoreVersion {
    guard newVersion != nil || newCopyright != nil else {
        throw AppStoreVersionError.noNewValuesSpecified
    }
    var attributes = AppStoreVersionUpdateRequest.Data.Attributes()
    var logValues = [String]()
    if let newVersion = newVersion {
        attributes.versionString = newVersion
        logValues.append("version '\(newVersion)'")
    }
    if let newCopyright = newCopyright {
        attributes.copyright = newCopyright
        logValues.append("copyright '\(newCopyright)'")
    }
    let requestBody = AppStoreVersionUpdateRequest(data: .init(id: id, attributes: attributes))
    ActionsEnvironment.logger.info("🚀 Updating App Store version with id '\(id)' with \(ListFormatter.localizedString(byJoining: logValues))...")
    let appStoreVersionResponse = try await ActionsEnvironment.service.request(
        .updateAppStoreVersion(id: id, requestBody: requestBody))
    ActionsEnvironment.logger.info("👍 App Store version updated")
    return appStoreVersionResponse.data
}
