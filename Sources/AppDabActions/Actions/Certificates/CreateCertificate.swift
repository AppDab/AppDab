import Bagbutik
import CertificateSigningRequest
import Foundation

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
    let certificateResponse = try await ActionsEnvironment.service.request(.createCertificate(requestBody: requestBody))
    ActionsEnvironment.logger.info("👍 Certificate created")
    return certificateResponse.data
}
