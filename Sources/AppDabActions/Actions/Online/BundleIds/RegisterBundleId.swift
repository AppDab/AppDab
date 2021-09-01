import Bagbutik

@discardableResult
public func registerBundleId(identifier: String, name: String, seedId: String? = nil) async throws -> BundleId {
    // No matter what platform is specified in the request, 'universal' will always be chosen by the API
    let requestBody = BundleIdCreateRequest(data: .init(attributes: .init(identifier: identifier, name: name, platform: .universal, seedId: seedId)))
    let fullIdentifier = BundleId.fullIdentifier(for: identifier, seedId: seedId)
    ActionsEnvironment.logger.info("🚀 Registering a new bundle ID '\(fullIdentifier)' called '\(name)' for \(platform.prettyName)")
    let bundleIdResponse = try await ActionsEnvironment.service.request(.createBundleId(requestBody: requestBody))
    ActionsEnvironment.logger.info("👍 Bundle ID registered")
    return bundleIdResponse.data
}
