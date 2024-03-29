import Bagbutik_Provisioning

/**
 Revoke a certificate by its resource id.
 
 - Parameters:
    - id: The id of the `Certificate` to revoke.
 */
public func revokeCertificate(withId id: String) async throws {
    ActionsEnvironment.logger.info("🚀 Revoking certificate '\(id)'...")
    _ = try await ActionsEnvironment.service.request(.deleteCertificateV1(id: id))
    ActionsEnvironment.logger.info("👍 Certificate revoked")
}

/**
 Revoke a certificate by its serial number.
 
 - Parameters:
    - serialNumber: The serial number of the `Certificate` to revoke.
 */
public func revokeCertificate(withSerialNumber serialNumber: String) async throws {
    ActionsEnvironment.logger.info("🚀 Fetching certificate by serial number '\(serialNumber)'...")
    guard let certificate = try await ActionsEnvironment.service.request(.listCertificatesV1(filters: [.serialNumber([serialNumber])])).data.first else {
        throw CertificateError.certificateWithSerialNumberNotFound(serialNumber)
    }
    ActionsEnvironment.logger.info("👍 Found certificate '\(serialNumber)' (\(certificate.id))")
    try await revokeCertificate(withId: certificate.id)
}

/**
 Revoke a certificate by its name.
 
 - Parameters:
    - name: The name of the `Certificate` to revoke.
 */
public func revokeCertificate(named name: String) async throws {
    ActionsEnvironment.logger.info("🚀 Fetching certificate by name '\(name)'...")
    guard let certificate = try await ActionsEnvironment.service.request(.listCertificatesV1(filters: [.displayName([name])])).data.first else {
        throw CertificateError.certificateWithNameNotFound(name)
    }
    ActionsEnvironment.logger.info("👍 Found certificate named '\(name)' (\(certificate.id))")
    try await revokeCertificate(withId: certificate.id)
}
