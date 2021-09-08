import Bagbutik
import Foundation

@discardableResult
public func listCertificates() async throws -> [Certificate] {
    ActionsEnvironment.logger.info("🚀 Fetching list of certificates...")
    let response = try await ActionsEnvironment.service.requestAllPages(.listCertificates())
    ActionsEnvironment.logger.info("👍 Certificates fetched")
    response.data.map(\.attributes).forEach { certificateAttributes in
        let expired = certificateAttributes!.expirationDate! < Date.now
        let expiredEmoji = expired ? "🔴" : "🟢"
        let expiresString = expired ? "expired" : "expires"
        ActionsEnvironment.logger.info(" ◦ \(expiredEmoji) \(certificateAttributes!.name!) (\(certificateAttributes!.serialNumber!)) \(expiresString) \(certificateAttributes!.expirationDate!.formatted(date: .abbreviated, time: .shortened))")
    }
    return response.data
}
