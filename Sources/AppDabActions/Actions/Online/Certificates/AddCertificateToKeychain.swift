import Bagbutik
import Foundation
import Security

public func addCertificateToKeychain(certificate: Certificate) throws {
    ActionsEnvironment.logger.info("💾 Adding certificate to Keychain...")
    guard
        let name = certificate.attributes?.name,
        let certificateContent = certificate.attributes?.certificateContent,
        let certificateData = Data(base64Encoded: certificateContent),
        let secCertificate = SecCertificateCreateWithData(nil, certificateData as CFData)
    else {
        throw AddCertificateToKeychainError.invalidOnlineCertificateData
    }
    try ActionsEnvironment.keychain.addCertificate(certificate: secCertificate, named: name)
    ActionsEnvironment.logger.info("👍 Certificate added to Keychain")
}
