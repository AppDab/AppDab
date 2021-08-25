import Bagbutik

public func renameBundleId(withId id: String, newName: String) async throws {
    let requestBody = BundleIdUpdateRequest(data: .init(id: id, attributes: .init(name: newName)))
    ActionsEnvironment.logger.info("🚀 Renaming bundle ID '\(id)' to '\(newName)'...")
    _ = try await ActionsEnvironment.service.request(.updateBundleId(id: id, requestBody: requestBody))
    ActionsEnvironment.logger.info("👍 Bundle ID renamed")
}

public func renameBundleId(withIdentifier identifier: String, newName: String) async throws {
    ActionsEnvironment.logger.info("🚀 Fetching bundle ID by identifier '\(identifier)'...")
    guard let bundleId = try await ActionsEnvironment.service.request(.listBundleIds(filters: [.identifier([identifier])])).data.first else {
        throw BundleIdError.bundleIdWithIdentifierNotFound(identifier)
    }
    ActionsEnvironment.logger.info("👍 Found bundle ID '\(identifier)' (\(bundleId.id))")
    try await renameBundleId(withId: bundleId.id, newName: newName)
}

public func renameBundleId(named name: String, newName: String) async throws {
    ActionsEnvironment.logger.info("🚀 Fetching bundle ID by name '\(name)'...")
    guard let bundleId = try await ActionsEnvironment.service.request(.listBundleIds(filters: [.name([name])])).data.first else {
        throw BundleIdError.bundleIdWithNameNotFound(name)
    }
    ActionsEnvironment.logger.info("👍 Found bundle ID named '\(name)' (\(bundleId.id))")
    try await renameBundleId(withId: bundleId.id, newName: newName)
}
