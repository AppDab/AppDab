import Bagbutik

/**
 Register a bundle id.

 - Parameters:
    - identifier: The identifier of the bundle id. This is the reverse-DNS identifier, like `com.apple.Calculator`.
    - name: The name of the bundle id.
    - seedId: The "App ID Prefix". This is typically the Team ID. If in doubt, leave it out.
 - Returns: The newly registered `BundleId`.
 */
@discardableResult
public func registerBundleId(identifier: String, name: String, seedId: String? = nil) async throws -> BundleId {
    // No matter what platform is specified in the request, 'universal' will always be chosen by the API
    let requestBody = BundleIdCreateRequest(data: .init(attributes: .init(identifier: identifier, name: name, platform: .universal, seedId: seedId)))
    let fullIdentifier = BundleId.fullIdentifier(for: identifier, seedId: seedId)
    ActionsEnvironment.logger.info("🚀 Registering a new bundle ID '\(fullIdentifier)' called '\(name)'")
    let bundleIdResponse = try await ActionsEnvironment.service.request(.createBundleIdV1(requestBody: requestBody))
    ActionsEnvironment.logger.info("👍 Bundle ID registered")
    return bundleIdResponse.data
}
