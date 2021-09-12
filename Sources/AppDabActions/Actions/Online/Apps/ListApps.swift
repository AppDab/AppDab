import Bagbutik

@discardableResult
public func listApps() async throws -> [App] {
    ActionsEnvironment.logger.info("🚀 Fetching list of apps...")
    let response = try await ActionsEnvironment.service.requestAllPages(.listApps())
    ActionsEnvironment.logger.info("👍 Apps fetched")
    response.data.map(\.attributes).forEach { appAttributes in
        ActionsEnvironment.logger.info(" ◦ \(appAttributes!.name!) (\(appAttributes!.bundleId!))")
    }
    return response.data
}

