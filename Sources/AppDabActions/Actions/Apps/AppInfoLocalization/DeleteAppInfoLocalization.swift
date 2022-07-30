import Bagbutik
import Foundation

/**
 Delete an app info localization.
 
 An app info localization is the localized parts of the App Store listing which isn't tied to a specific version.
 
 - Parameters:
    - id: The id of the `AppInfoLocalization` to delete.
 */
public func deleteAppInfoLocalization(withId id: String) async throws {
    ActionsEnvironment.logger.info("🚀 Deleting localization '\(id)'...")
    _ = try await ActionsEnvironment.service.request(.deleteAppInfoLocalizationV1(id: id))
    ActionsEnvironment.logger.info("👍 Localization deleted")
}
