import Bagbutik
import Foundation

public func deleteAppInfoLocalization(withId id: String) async throws {
    ActionsEnvironment.logger.info("🚀 Deleting localization '\(id)'...")
    _ = try await ActionsEnvironment.service.request(.deleteAppInfoLocalization(id: id))
    ActionsEnvironment.logger.info("👍 Localization deleted")
}
