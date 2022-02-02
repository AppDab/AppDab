import Bagbutik

@discardableResult
public func listUserInvitations() async throws -> [UserInvitation] {
    ActionsEnvironment.logger.info("🚀 Fetching list of user invitations...")
    let response = try await ActionsEnvironment.service.requestAllPages(.listUserInvitations())
    ActionsEnvironment.logger.info("👍 User invitations fetched")
    response.data.map(\.attributes).forEach { userAttributes in
        ActionsEnvironment.logger.info(" ◦ \(userAttributes!.firstName!) \(userAttributes!.lastName!) (\(userAttributes!.email!))")
    }
    return response.data
}
