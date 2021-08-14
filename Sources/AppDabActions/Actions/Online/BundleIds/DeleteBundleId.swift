import Bagbutik

public func deleteBundleId(withId id: String) throws {
    ActionsEnvironment.logger.info("🚀 Deleting bundle ID '\(id)'...")
    _ = try ActionsEnvironment.service.requestSynchronously(.deleteBundleId(id: id)).get()
    ActionsEnvironment.logger.info("👍 Bundle ID deleted")
}

public func deleteBundleId(withIdentifier identifier: String) throws {
    ActionsEnvironment.logger.info("🚀 Fetching bundle ID by identifier '\(identifier)'...")
    guard let bundleId = try ActionsEnvironment.service.requestSynchronously(.listBundleIds(filters: [.identifier([identifier])])).get().data.first else {
        throw BundleIdError.bundleIdWithIdentifierNotFound(identifier)
    }
    ActionsEnvironment.logger.info("👍 Found bundle ID '\(identifier)' (\(bundleId.id))")
    try deleteBundleId(withId: bundleId.id)
}

public func deleteBundleId(named name: String) throws {
    ActionsEnvironment.logger.info("🚀 Fetching bundle ID by name '\(name)'...")
    guard let bundleId = try ActionsEnvironment.service.requestSynchronously(.listBundleIds(filters: [.name([name])])).get().data.first else {
        throw BundleIdError.bundleIdWithNameNotFound(name)
    }
    ActionsEnvironment.logger.info("👍 Found bundle ID named '\(name)' (\(bundleId.id))")
    try deleteBundleId(withId: bundleId.id)
}
