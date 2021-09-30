import Bagbutik
import Foundation

@discardableResult
public func listProfiles() async throws -> [Profile] {
    ActionsEnvironment.logger.info("🚀 Fetching list of profiles...")
    let response = try await ActionsEnvironment.service.requestAllPages(.listProfiles())
    ActionsEnvironment.logger.info("👍 Profiles fetched")
    response.data.map(\.attributes).forEach { profileAttributes in
        let expired = profileAttributes!.expirationDate! < Date.now
        let expiresString = expired ? "expired" : "expires"
        let activeEmoji = profileAttributes!.profileState! != .active || expired ? "🔴" : "🟢"
        ActionsEnvironment.logger.info(" ◦ \(activeEmoji) \(profileAttributes!.name!) (\(profileAttributes!.uuid!)) \(expiresString) \(profileAttributes!.expirationDate!.formatted(date: .abbreviated, time: .shortened))")
    }
    ActionsEnvironment.logger.info("⚠️ Expired profiles are only shown in the Developer Portal: https://developer.apple.com/account/resources/profiles/list")
    return response.data
}
