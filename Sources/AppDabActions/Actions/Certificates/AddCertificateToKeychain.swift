import Bagbutik
import Foundation
import Security

public func addCertificateToKeychain(certificate: Certificate) throws {
    logStartInfo()
    guard
        let name = certificate.attributes?.name,
        let certificateContent = certificate.attributes?.certificateContent
    else {
        throw AddCertificateToKeychainError.invalidOnlineCertificateData
    }
    try _addCertificateToKeychain(named: name, certificateContent: certificateContent)
}

public func addCertificateToKeychain(named name: String, certificateContent: String) throws {
    logStartInfo()
    try _addCertificateToKeychain(named: name, certificateContent: certificateContent)
}

private func logStartInfo() {
    ActionsEnvironment.logger.info("🔐 Adding certificate to Keychain...")
}

private func _addCertificateToKeychain(named name: String, certificateContent: String) throws {
    guard
        let certificateData = Data(base64Encoded: certificateContent),
        let secCertificate = SecCertificateCreateWithData(nil, certificateData as CFData)
    else {
        throw AddCertificateToKeychainError.invalidOnlineCertificateData
    }
    try ActionsEnvironment.keychain.addCertificate(certificate: secCertificate, named: name)
    ActionsEnvironment.logger.info("👍 Certificate added to Keychain")
}
