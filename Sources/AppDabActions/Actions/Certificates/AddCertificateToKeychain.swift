import Bagbutik_Models
import Bagbutik_Provisioning
import Foundation
import Security

/**
 Add a certificate to Keychain.
 
 - Parameters:
    - certificate: The `Certificate` to add to Keychain.
 */
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

/**
 Add a certificate to Keychain and label it.
 
 - Parameters:
    - name: The name to label the certificate with in Keychain.
    - certificateContent: The content of a certificate to add to Keychain.
 */
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
