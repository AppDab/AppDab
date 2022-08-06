import Bagbutik_AppStore
import Bagbutik_Models

/**
 List all apps.

 - Returns: An array of all the apps.
 */
@discardableResult
public func listApps() async throws -> [App] {
    ActionsEnvironment.logger.info("🚀 Fetching list of apps...")
    let response = try await ActionsEnvironment.service.requestAllPages(.listAppsV1())
    ActionsEnvironment.logger.info("👍 Apps fetched")
    response.data.map(\.attributes).forEach { appAttributes in
        ActionsEnvironment.logger.info(" ◦ \(appAttributes!.name!) (\(appAttributes!.bundleId!))")
    }
    return response.data
}
