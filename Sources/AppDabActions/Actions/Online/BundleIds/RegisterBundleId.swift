import Bagbutik

@discardableResult
public func registerBundleId(identifier: String, name: String, platform: BundleIdPlatform, seedId: String? = nil) async throws -> BundleId {
    let requestBody = BundleIdCreateRequest(data: .init(attributes: .init(identifier: identifier, name: name, platform: platform, seedId: seedId)))
    let fullIdentifier = BundleId.fullIdentifier(for: identifier, seedId: seedId)
    ActionsEnvironment.logger.info("🚀 Registering a new bundle ID '\(fullIdentifier)' called '\(name)' for \(platform.prettyName)")
    let bundleIdResponse = try await ActionsEnvironment.service.request(.createBundleId(requestBody: requestBody))
    ActionsEnvironment.logger.info("👍 Bundle ID registered")
    return bundleIdResponse.data
}
