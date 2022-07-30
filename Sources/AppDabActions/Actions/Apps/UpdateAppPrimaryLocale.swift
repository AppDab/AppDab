import Bagbutik

/**
 Update the primary locale for an app.

 - Parameters:
    - appId: The id of the `App` to be updated.
    - newPrimaryLocale: The new primary locale for the app.
 - Returns: The updated `App`.
 */
@discardableResult
public func updateAppPrimaryLocale(forAppId appId: String, newPrimaryLocale: String) async throws -> App {
    let requestBody = AppUpdateRequest(data: .init(id: appId, attributes: .init(primaryLocale: newPrimaryLocale)), included: [])
    ActionsEnvironment.logger.info("🚀 Updating primary locale '\(newPrimaryLocale)' for app with id '\(appId)'...")
    let appResponse = try await ActionsEnvironment.service.request(.updateAppV1(id: appId, requestBody: requestBody))
    ActionsEnvironment.logger.info("👍 Primary locale updated")
    return appResponse.data
}
