import Bagbutik_Provisioning

/**
 Delete a profile by its resource id.
 
 - Parameters:
    - id: The id of the `Profile` to delete.
 */
public func deleteProfile(withId id: String) async throws {
    ActionsEnvironment.logger.info("🚀 Deleting profile '\(id)'...")
    _ = try await ActionsEnvironment.service.request(.deleteProfileV1(id: id))
    ActionsEnvironment.logger.info("👍 Profile deleted")
}

/**
 Delete a profile by its name.
 
 - Parameters:
    - name: The name of the `Profile` to delete.
 */
public func deleteProfile(named name: String) async throws {
    ActionsEnvironment.logger.info("🚀 Fetching profile by name '\(name)'...")
    guard let profile = try await ActionsEnvironment.service.request(.listProfilesV1(filters: [.name([name])])).data.first else {
        throw ProfileError.profileWithNameNotFound(name)
    }
    ActionsEnvironment.logger.info("👍 Found profile named '\(name)' (\(profile.id))")
    try await deleteProfile(withId: profile.id)
}
