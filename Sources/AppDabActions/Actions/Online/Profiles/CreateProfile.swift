import Bagbutik

@discardableResult
public func createProfile(named name: String, profileType: Profile.Attributes.ProfileType, bundleIdId: String, certificateIds: [String], deviceIds: [String]) async throws -> Profile {
    guard let profileType = ProfileCreateRequest.Data.Attributes.ProfileType(rawValue: profileType.rawValue) else {
        throw ProfileError.profileTypeCantBeCreated(profileType) // This will only happen if the enums don't match someday
    }
    let requestBody = ProfileCreateRequest(
        data: .init(
            attributes: .init(name: name, profileType: profileType),
            relationships: .init(
                bundleId: .init(data: .init(id: bundleIdId)),
                certificates: .init(data: certificateIds.map(ProfileCreateRequest.Data.Relationships.Certificates.Data.init(id:))),
                devices: .init(data: deviceIds.map(ProfileCreateRequest.Data.Relationships.Devices.Data.init(id:)))
            )
        )
    )
    ActionsEnvironment.logger.info("🚀 Creating a new profile called '\(name)'...")
    let profileResponse = try await ActionsEnvironment.service.request(.createProfile(requestBody: requestBody))
    ActionsEnvironment.logger.info("👍 Profile created")
    return profileResponse.data
}
