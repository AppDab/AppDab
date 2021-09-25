import Bagbutik

public func deleteProfile(withId id: String) async throws {
    ActionsEnvironment.logger.info("🚀 Deleting profile '\(id)'...")
    _ = try await ActionsEnvironment.service.request(.deleteProfile(id: id))
    ActionsEnvironment.logger.info("👍 Profile deleted")
}

public func deleteProfile(named name: String) async throws {
    ActionsEnvironment.logger.info("🚀 Fetching profile by name '\(name)'...")
    guard let profile = try await ActionsEnvironment.service.request(.listProfiles(filters: [.name([name])])).data.first else {
        throw ProfileError.profileWithNameNotFound(name)
    }
    ActionsEnvironment.logger.info("👍 Found profile named '\(name)' (\(profile.id))")
    try await deleteProfile(withId: profile.id)
}
