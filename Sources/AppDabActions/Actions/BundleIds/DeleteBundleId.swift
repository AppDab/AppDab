import Bagbutik_Provisioning

/**
 Delete a bundle id by its resource id.
 
 - Parameters:
    - id: The id of the `BundleId` to delete.
 */
public func deleteBundleId(withId id: String) async throws {
    ActionsEnvironment.logger.info("🚀 Deleting bundle ID '\(id)'...")
    _ = try await ActionsEnvironment.service.request(.deleteBundleIdV1(id: id))
    ActionsEnvironment.logger.info("👍 Bundle ID deleted")
}

/**
 Delete a bundle id by its identifier.
 
 The identifier is the reverse-DNS identifier, like `com.apple.Calculator`.
 
 - Parameters:
    - identifier: The identifier of the `BundleId` to delete.
 */
public func deleteBundleId(withIdentifier identifier: String) async throws {
    ActionsEnvironment.logger.info("🚀 Fetching bundle ID by identifier '\(identifier)'...")
    guard let bundleId = try await ActionsEnvironment.service.request(.listBundleIdsV1(filters: [.identifier([identifier])])).data.first else {
        throw BundleIdError.bundleIdWithIdentifierNotFound(identifier)
    }
    ActionsEnvironment.logger.info("👍 Found bundle ID '\(identifier)' (\(bundleId.id))")
    try await deleteBundleId(withId: bundleId.id)
}

/**
 Delete a bundle id by its name.
 
 - Parameters:
    - name: The name of the `BundleId` to delete.
 */
public func deleteBundleId(named name: String) async throws {
    ActionsEnvironment.logger.info("🚀 Fetching bundle ID by name '\(name)'...")
    guard let bundleId = try await ActionsEnvironment.service.request(.listBundleIdsV1(filters: [.name([name])])).data.first else {
        throw BundleIdError.bundleIdWithNameNotFound(name)
    }
    ActionsEnvironment.logger.info("👍 Found bundle ID named '\(name)' (\(bundleId.id))")
    try await deleteBundleId(withId: bundleId.id)
}
