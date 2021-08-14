import Bagbutik

public func inviteUser(email: String, firstName: String, lastName: String, roles: [UserRole], allAppsVisible: Bool = false, provisioningAllowed: Bool = false, visibleAppIds: [String]? = nil) throws {
    var relationships: UserInvitationCreateRequest.Data.Relationships? = nil
    if let visibleAppsData = visibleAppIds?.map({ UserInvitationCreateRequest.Data.Relationships.VisibleApps.Data(id: $0) }) {
        relationships = .init(visibleApps: .init(data: visibleAppsData))
    }
    let requestBody = UserInvitationCreateRequest(data: .init(
        attributes: .init(allAppsVisible: allAppsVisible, email: email, firstName: firstName, lastName: lastName, provisioningAllowed: provisioningAllowed, roles: roles),
        relationships: relationships))
    ActionsEnvironment.logger.info("🚀 Inviting user '\(firstName) \(lastName)' (\(email))...")
    _ = try ActionsEnvironment.service.requestSynchronously(.createUserInvitation(requestBody: requestBody)).get()
    ActionsEnvironment.logger.info("👍 User invited")
}
