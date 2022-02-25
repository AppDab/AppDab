import Bagbutik
import Foundation

/**
 List all certificates.

 - Returns: An array of all the certificates and an indication of if the certificate is present in Keychain.
 */
@discardableResult
public func listCertificates() async throws -> [(certificate: Certificate, inKeychain: Bool)] {
    ActionsEnvironment.logger.info("🚀 Fetching list of certificates...")
    let response = try await ActionsEnvironment.service.requestAllPages(.listCertificates())
    ActionsEnvironment.logger.info("👍 Certificates fetched")
    let serialNumbers = response.data.map { $0.attributes!.serialNumber! }
    let keychainStatuses = try ActionsEnvironment.keychain.hasCertificates(serialNumbers: serialNumbers)
    response.data.map(\.attributes).forEach { certificateAttributes in
        let expired = certificateAttributes!.expirationDate! < Date.now
        let expiredEmoji = expired ? "🔴" : "🟢"
        let expiresString = expired ? "expired" : "expires"
        let serialNumber = certificateAttributes!.serialNumber!
        let keychainStatus = (keychainStatuses[serialNumber] ?? false ? "" : "NOT ") + "in local Keychain,"
        ActionsEnvironment.logger.info(" ◦ \(expiredEmoji) \(certificateAttributes!.name!) (\(serialNumber)) \(keychainStatus) \(expiresString) \(certificateAttributes!.expirationDate!.formatted(date: .abbreviated, time: .omitted))")
    }
    return response.data.map { certificate in
        (certificate: certificate, inKeychain: keychainStatuses[certificate.attributes!.serialNumber!] ?? false)
    }
}
