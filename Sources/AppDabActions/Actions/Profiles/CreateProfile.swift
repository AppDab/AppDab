import Bagbutik_Models
import Bagbutik_Provisioning

/**
 Create a profile.

 - Parameters:
    - name: The name of the profile.
    - profileType: The type of the profile.
    - bundleIdId: The id of the related `BundleId`.
    - certificateIds: The ids of the related `Certificate`s.
    - deviceIds: The ids of the related `Device`s.
 - Returns: The newly created `Profile`.
 */
@discardableResult
public func createProfile(named name: String, profileType: Profile.Attributes.ProfileType, bundleIdId: String, certificateIds: [String], deviceIds: [String]) async throws -> Profile {
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
    let profileResponse = try await ActionsEnvironment.service.request(.createProfileV1(requestBody: requestBody))
    ActionsEnvironment.logger.info("👍 Profile created")
    return profileResponse.data
}
