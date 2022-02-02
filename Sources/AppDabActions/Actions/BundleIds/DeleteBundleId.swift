import Bagbutik

public func deleteBundleId(withId id: String) async throws {
    ActionsEnvironment.logger.info("🚀 Deleting bundle ID '\(id)'...")
    _ = try await ActionsEnvironment.service.request(.deleteBundleId(id: id))
    ActionsEnvironment.logger.info("👍 Bundle ID deleted")
}

public func deleteBundleId(withIdentifier identifier: String) async throws {
    ActionsEnvironment.logger.info("🚀 Fetching bundle ID by identifier '\(identifier)'...")
    guard let bundleId = try await ActionsEnvironment.service.request(.listBundleIds(filters: [.identifier([identifier])])).data.first else {
        throw BundleIdError.bundleIdWithIdentifierNotFound(identifier)
    }
    ActionsEnvironment.logger.info("👍 Found bundle ID '\(identifier)' (\(bundleId.id))")
    try await deleteBundleId(withId: bundleId.id)
}

public func deleteBundleId(named name: String) async throws {
    ActionsEnvironment.logger.info("🚀 Fetching bundle ID by name '\(name)'...")
    guard let bundleId = try await ActionsEnvironment.service.request(.listBundleIds(filters: [.name([name])])).data.first else {
        throw BundleIdError.bundleIdWithNameNotFound(name)
    }
    ActionsEnvironment.logger.info("👍 Found bundle ID named '\(name)' (\(bundleId.id))")
    try await deleteBundleId(withId: bundleId.id)
}
