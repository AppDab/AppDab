import Bagbutik

/**
 List all users.

 - Returns: An array of all the users.
 */
@discardableResult
public func listUsers() async throws -> [User] {
    ActionsEnvironment.logger.info("🚀 Fetching list of users...")
    let response = try await ActionsEnvironment.service.requestAllPages(.listUsersV1())
    ActionsEnvironment.logger.info("👍 Users fetched")
    response.data.map(\.attributes).forEach { userAttributes in
        ActionsEnvironment.logger.info(" ◦ \(userAttributes!.firstName!) \(userAttributes!.lastName!) (\(userAttributes!.username!))")
    }
    return response.data
}
