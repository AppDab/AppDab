import Bagbutik

/**
 Rename a bundle id by its resource id.

 - Parameters:
    - id: The id of the `BundleId` to be updated.
    - newName: The new name for the bundle id.
 - Returns: The updated `BundleId`.
 */
@discardableResult
public func renameBundleId(withId id: String, newName: String) async throws -> BundleId {
    let requestBody = BundleIdUpdateRequest(data: .init(id: id, attributes: .init(name: newName)))
    ActionsEnvironment.logger.info("🚀 Renaming bundle ID '\(id)' to '\(newName)'...")
    let bundleIdResponse = try await ActionsEnvironment.service.request(.updateBundleId(id: id, requestBody: requestBody))
    ActionsEnvironment.logger.info("👍 Bundle ID renamed")
    return bundleIdResponse.data
}

/**
 Rename a bundle id by its identifier.
 
 The identifier is the reverse-DNS identifier, like `com.apple.Calculator`.

 - Parameters:
    - identifier: The identifier of the `BundleId` to be updated.
    - newName: The new name for the bundle id.
 - Returns: The updated `BundleId`.
 */
@discardableResult
public func renameBundleId(withIdentifier identifier: String, newName: String) async throws -> BundleId {
    ActionsEnvironment.logger.info("🚀 Fetching bundle ID by identifier '\(identifier)'...")
    guard let bundleId = try await ActionsEnvironment.service.request(.listBundleIds(filters: [.identifier([identifier])])).data.first else {
        throw BundleIdError.bundleIdWithIdentifierNotFound(identifier)
    }
    ActionsEnvironment.logger.info("👍 Found bundle ID '\(identifier)' (\(bundleId.id))")
    return try await renameBundleId(withId: bundleId.id, newName: newName)
}

/**
 Rename a bundle id by its current name.
 
 - Parameters:
    - name: The name of the `BundleId` to be updated.
    - newName: The new name for the bundle id.
 - Returns: The updated `BundleId`.
 */
@discardableResult
public func renameBundleId(named name: String, newName: String) async throws -> BundleId {
    ActionsEnvironment.logger.info("🚀 Fetching bundle ID by name '\(name)'...")
    guard let bundleId = try await ActionsEnvironment.service.request(.listBundleIds(filters: [.name([name])])).data.first else {
        throw BundleIdError.bundleIdWithNameNotFound(name)
    }
    ActionsEnvironment.logger.info("👍 Found bundle ID named '\(name)' (\(bundleId.id))")
    return try await renameBundleId(withId: bundleId.id, newName: newName)
}
