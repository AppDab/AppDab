import Bagbutik_Models
import Bagbutik_Provisioning
import CertificateSigningRequest
import Foundation

/**
 Create a new certificate of a specific type.

 - Parameters:
    - type: The type of certificate to create.
 - Returns: The newly created `Certificate`.
 */
@discardableResult
public func createCertificate(type: CertificateType) async throws -> Certificate {
    let label = "AppDab \(Date().timeIntervalSince1970)"
    let privateKey = try ActionsEnvironment.keychain.createPrivateKey(labeled: label)
    let publicKey = try ActionsEnvironment.keychain.createPublicKey(from: privateKey)
    let csr = CertificateSigningRequest()
    guard let csrString = csr.buildCSRAndReturnString(publicKey.data as Data, privateKey: privateKey, publicKey: publicKey.key) else {
        throw CreateCertificateError.errorCreatingSigningRequest
    }
    let requestBody = CertificateCreateRequest(data: .init(attributes: .init(certificateType: type, csrContent: csrString)))
    ActionsEnvironment.logger.info("🚀 Creating a '\(type.prettyName)' certificate...")
    let certificateResponse = try await ActionsEnvironment.service.request(.createCertificateV1(requestBody: requestBody))
    ActionsEnvironment.logger.info("👍 Certificate created")
    return certificateResponse.data
}
