import Bagbutik

@discardableResult
public func listBundleIds() async throws -> [BundleId] {
    ActionsEnvironment.logger.info("🚀 Fetching list of bundle IDs...")
    let response = try await ActionsEnvironment.service.requestAllPages(.listBundleIds())
    ActionsEnvironment.logger.info("👍 Bundle IDs fetched")
    response.data.map(\.attributes).forEach { bundleIdsAttributes in
        let fullIdentifier = BundleId.fullIdentifier(for: bundleIdsAttributes!.identifier!, seedId: bundleIdsAttributes?.seedId)
        ActionsEnvironment.logger.info(" ◦ \(bundleIdsAttributes!.name!) (\(fullIdentifier)) for \(bundleIdsAttributes!.platform!.prettyName)")
    }
    return response.data
}
