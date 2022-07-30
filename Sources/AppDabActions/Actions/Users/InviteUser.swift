import Bagbutik

/**
 Create a user.

 - Parameters:
    - email: The email address of the user.
    - firstName: The first name of the user.
    - lastName: The last name of the user.
    - roles: The roles the user should have.
    - allAppsVisible: Should the user have access to all apps available to the team?
    - provisioningAllowed: Should the user have access to provisioning functionality on the Apple Developer website?
    - visibleAppIds: The ids of the `App`s the user have access to.
 - Returns: The newly created `UserInvitation`.
 */
@discardableResult
public func inviteUser(email: String, firstName: String, lastName: String, roles: [UserRole], allAppsVisible: Bool = false, provisioningAllowed: Bool = false, visibleAppIds: [String]? = nil) async throws -> UserInvitation {
    var relationships: UserInvitationCreateRequest.Data.Relationships?
    if let visibleAppsData = visibleAppIds?.map({ UserInvitationCreateRequest.Data.Relationships.VisibleApps.Data(id: $0) }) {
        relationships = .init(visibleApps: .init(data: visibleAppsData))
    }
    let requestBody = UserInvitationCreateRequest(data: .init(
        attributes: .init(allAppsVisible: allAppsVisible, email: email, firstName: firstName, lastName: lastName, provisioningAllowed: provisioningAllowed, roles: roles),
        relationships: relationships))
    ActionsEnvironment.logger.info("🚀 Inviting user '\(firstName) \(lastName)' (\(email))...")
    let userInvitationResponse = try await ActionsEnvironment.service.request(.createUserInvitationV1(requestBody: requestBody))
    ActionsEnvironment.logger.info("👍 User invited")
    return userInvitationResponse.data
}
