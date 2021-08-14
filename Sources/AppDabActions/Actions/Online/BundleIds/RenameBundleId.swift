import Bagbutik

public func renameBundleId(withId id: String, newName: String) throws {
    let requestBody = BundleIdUpdateRequest(data: .init(id: id, attributes: .init(name: newName)))
    ActionsEnvironment.logger.info("🚀 Renaming bundle ID '\(id)' to '\(newName)'...")
    _ = try ActionsEnvironment.service.requestSynchronously(.updateBundleId(id: id, requestBody: requestBody)).get()
    ActionsEnvironment.logger.info("👍 Bundle ID renamed")
}

public func renameBundleId(withIdentifier identifier: String, newName: String) throws {
    ActionsEnvironment.logger.info("🚀 Fetching bundle ID by identifier '\(identifier)'...")
    guard let bundleId = try ActionsEnvironment.service.requestSynchronously(.listBundleIds(filters: [.identifier([identifier])])).get().data.first else {
        throw BundleIdError.bundleIdWithIdentifierNotFound(identifier)
    }
    ActionsEnvironment.logger.info("👍 Found bundle ID '\(identifier)' (\(bundleId.id))")
    try renameBundleId(withId: bundleId.id, newName: newName)
}

public func renameBundleId(named name: String, newName: String) throws {
    ActionsEnvironment.logger.info("🚀 Fetching bundle ID by name '\(name)'...")
    guard let bundleId = try ActionsEnvironment.service.requestSynchronously(.listBundleIds(filters: [.name([name])])).get().data.first else {
        throw BundleIdError.bundleIdWithNameNotFound(name)
    }
    ActionsEnvironment.logger.info("👍 Found bundle ID named '\(name)' (\(bundleId.id))")
    try renameBundleId(withId: bundleId.id, newName: newName)
}
