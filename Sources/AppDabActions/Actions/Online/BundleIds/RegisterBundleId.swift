import Bagbutik

public func registerBundleId(identifier: String, name: String, platform: BundleIdPlatform, seedId: String? = nil) async throws {
    let requestBody = BundleIdCreateRequest(data: .init(attributes: .init(identifier: identifier, name: name, platform: platform, seedId: seedId)))
    let fullIdentifier: String
    if let seedId = seedId {
        fullIdentifier = "\(seedId).\(identifier)"
    } else {
        fullIdentifier = identifier
    }
    ActionsEnvironment.logger.info("🚀 Registering a new bundle ID '\(fullIdentifier)' called '\(name)' for \(platform.prettyName)")
    _ = try await ActionsEnvironment.service.request(.createBundleId(requestBody: requestBody))
    ActionsEnvironment.logger.info("👍 Bundle ID registered")
}
