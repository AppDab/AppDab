import Bagbutik

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
    let userInvitationResponse = try await ActionsEnvironment.service.request(.createUserInvitation(requestBody: requestBody))
    ActionsEnvironment.logger.info("👍 User invited")
    return userInvitationResponse.data
}
