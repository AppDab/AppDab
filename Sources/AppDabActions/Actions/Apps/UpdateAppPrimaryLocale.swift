import Bagbutik

@discardableResult
public func updateAppPrimaryLocale(forAppId appId: String, newPrimaryLocale: String) async throws -> App {
    let requestBody = AppUpdateRequest(data: .init(id: appId, attributes: .init(primaryLocale: newPrimaryLocale)), included: [])
    ActionsEnvironment.logger.info("🚀 Updating primary locale '\(newPrimaryLocale)' for app with id '\(appId)'...")
    let appResponse = try await ActionsEnvironment.service.request(.updateApp(id: appId, requestBody: requestBody))
    ActionsEnvironment.logger.info("👍 Primary locale updated")
    return appResponse.data
}
