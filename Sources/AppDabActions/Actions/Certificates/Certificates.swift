#if os(macOS)
import Bagbutik
import CertificateSigningRequest
import Foundation

public func ensureCertificate(type: ListCertificates.Filter.CertificateType = .distribution, policy: EnsureCertificatePolicy = .readOnly, encryptedCertificatesFolderPath: String? = nil, certificateSerialNumber requestedCertificateSerialNumber: String? = nil) async throws {
    ActionsEnvironment.logger.info("⏬ Fetching list of available certificates...")
    var filters: [ListCertificates.Filter] = [.certificateType([type])]
    if let requestedCertificateSerialNumber = requestedCertificateSerialNumber {
        filters.append(.serialNumber([requestedCertificateSerialNumber]))
    }
    let certificates = try await ActionsEnvironment.service.request(.listCertificates(filters: filters)).data
    let encryptedCertificatesFolderPath = encryptedCertificatesFolderPath ?? "Signing"
    guard certificates.count > 0 else {
        ActionsEnvironment.logger.info("🤷🏼 No certificates found online")
        if ActionsEnvironment.terminal.getBoolInput(question: "Should we create a new certificate?") {
            try await maybeCreateCertificate(type: type, policy: policy, encryptedCertificatesFolderPath: encryptedCertificatesFolderPath)
        } else {
            ActionsEnvironment.logger.info("🙅🏼 Won't create a new certificate")
        }
        return
    }

    ActionsEnvironment.logger.info("🔍 Looking for a matching certificate in Keychain...")
    // Are there any certificates matching in Keychain?
    if let (certificate, identity) = try findFirstMatchingCertificateInKeychain(certificates: certificates) {
        guard let expirationDate = certificate.attributes?.expirationDate,
              let serialNumber = certificate.attributes?.serialNumber
        else {
            throw CertificateError.invalidOnlineCertificateData
        }
        // Has the certificate expired?
        if expirationDate > Date() {
            ActionsEnvironment.logger.info("🎉 A certificate is available in Keychain for signing. Expires \(Formatters.relativeDateTimeFormatter.localizedString(for: expirationDate, relativeTo: Date())) (\(Formatters.dateTimeFormatter.string(from: expirationDate)))")
            try exportIdentity(certificateSerialNumber: serialNumber, identity: identity, encryptedCertificatesFolderPath: encryptedCertificatesFolderPath)
        } else {
            ActionsEnvironment.logger.info("⏰ The certificate expired \(Formatters.dateTimeFormatter.string(from: expirationDate))")
            try await maybeCreateCertificate(type: type, policy: policy, encryptedCertificatesFolderPath: encryptedCertificatesFolderPath)
        }
    } else {
        ActionsEnvironment.logger.info("🤷🏼 No certificates found in Keychain")
        let certificate: Certificate
        if certificates.count > 1 {
            let items = try certificates.map { certificate -> String in
                guard let displayName = certificate.attributes?.displayName,
                      let expirationDate = certificate.attributes?.expirationDate
                else {
                    throw CertificateError.invalidOnlineCertificateData
                }
                return "\(displayName) (\(Formatters.dateTimeFormatter.string(from: expirationDate)))"
            }
            let (index, _) = try ActionsEnvironment.terminal.selectOption(text: "Multiple certificates available online. Which certificate should be used?", items: items)
            certificate = certificates[index]
        } else {
            certificate = certificates[0]
        }
        guard let serialNumber = certificate.attributes?.serialNumber else {
            throw CertificateError.invalidOnlineCertificateData
        }
        ActionsEnvironment.logger.info("🔍 Looking for saved certificate and private key...")
        let allItemsInFolder = try FileManager.default.contentsOfDirectory(atPath: encryptedCertificatesFolderPath)
        guard let p12FileName = allItemsInFolder.first(where: { $0.contains(serialNumber) }) else {
            let saveCertificateResult = try saveCertificateInKeychain(certificate: certificate, encryptedCertificatesFolderPath: encryptedCertificatesFolderPath)
            if case .success = saveCertificateResult {
                return
            } else {
                if case .privateKeyForCertificateNotFound = saveCertificateResult {
                    ActionsEnvironment.logger.info("🤷🏼 The private key for the certificate was not found")
                } else {
                    ActionsEnvironment.logger.info("🤷🏼 No saved certificate and private key found")
                }
                if ActionsEnvironment.terminal.getBoolInput(question: "Should we create a new certificate?") {
                    try await maybeCreateCertificate(type: type, policy: policy, encryptedCertificatesFolderPath: encryptedCertificatesFolderPath)
                } else {
                    ActionsEnvironment.logger.info("🙅🏼 Won't create a new certificate")
                }
                return
            }
        }
        let p12Path = "\(encryptedCertificatesFolderPath)/\(p12FileName)"
        ActionsEnvironment.logger.info("👍 Found saved certificate and private key")
        ActionsEnvironment.logger.trace("Saved certificate and private key is here: \(p12Path)")
        var passphrase: String
        var shouldSavePassphrase: Bool
        let foundSavedPassphrase: Bool
        if let savedPassphrase = try? Keychain().readP12Passphrase(certificateSerialNumber: serialNumber) {
            ActionsEnvironment.logger.trace("Found saved passphrase in Keychain")
            passphrase = savedPassphrase
            shouldSavePassphrase = false
            foundSavedPassphrase = true
        } else {
            ActionsEnvironment.logger.warning("Enter passphrase for the exported certificate and private key:")
            passphrase = ActionsEnvironment.terminal.getInput(secret: true)
            shouldSavePassphrase = true
            foundSavedPassphrase = false
        }
        do {
            try Keychain().importPCKS12(atPath: p12Path, passphrase: passphrase)
        } catch KeychainError.wrongPassphraseForP12 {
            if foundSavedPassphrase {
                ActionsEnvironment.logger.warning("Saved passphrase didn't match. Enter the passphrase for the exported certificate and private key:")
            } else {
                ActionsEnvironment.logger.warning("Entered passphrase didn't match. Enter the passphrase, to try again:")
            }
            passphrase = ActionsEnvironment.terminal.getInput(secret: true)
            shouldSavePassphrase = true
            try Keychain().importPCKS12(atPath: p12Path, passphrase: passphrase)
        } catch {
            throw error
        }
        ActionsEnvironment.logger.info("👍 Certificate and private key imported in Keychain")
        if shouldSavePassphrase {
            try savePassphraseInKeychain(passphrase, certificateSerialNumber: serialNumber)
        }
    }
}

private enum SaveCertificateResult {
    case success
    case privateKeyForCertificateNotFound
    case unknown(OSStatus)
}

private func saveCertificateInKeychain(certificate: Certificate, encryptedCertificatesFolderPath: String) throws -> SaveCertificateResult {
    guard
        let name = certificate.attributes?.name,
        let serialNumber = certificate.attributes?.serialNumber,
        let certificateContent = certificate.attributes?.certificateContent,
        let certificateData = Data(base64Encoded: certificateContent),
        let secCertificate = SecCertificateCreateWithData(nil, certificateData as CFData)
    else {
        throw CertificateError.invalidOnlineCertificateData
    }
    var identity: SecIdentity?
    let createIdentityStatus = SecIdentityCreateWithCertificate(nil, secCertificate, &identity)
    if createIdentityStatus == errSecSuccess, let identity = identity {
        let addquery: [String: Any] = [kSecClass as String: kSecClassCertificate,
                                       kSecValueRef as String: secCertificate,
                                       kSecAttrLabel as String: name]
        let addStatus = SecItemAdd(addquery as CFDictionary, nil)
        guard addStatus == errSecSuccess else {
            throw CertificateError.errorAddingCertificateToKeychain
        }
        ActionsEnvironment.logger.info("🎉 The certificate was added to Keychain")
        try exportIdentity(certificateSerialNumber: serialNumber, identity: identity, encryptedCertificatesFolderPath: encryptedCertificatesFolderPath)
        return .success
    } else if createIdentityStatus == errSecItemNotFound {
        return .privateKeyForCertificateNotFound
    } else {
        return .unknown(createIdentityStatus)
    }
}

private func maybeCreateCertificate(type: ListCertificates.Filter.CertificateType, policy: EnsureCertificatePolicy, encryptedCertificatesFolderPath: String) async throws {
    if policy == .readOnly {
        ActionsEnvironment.logger.error("🚫 In read-only mode, so no new certificate is created")
    } else {
        guard let typeToCreate = CertificateType(rawValue: type.rawValue) else {
            throw CertificateError.typeCantBeCreated
        }
        let label = "AppDab \(Date().timeIntervalSince1970)"
        let privateKey = try Keychain().createPrivateKey(labeled: label)
        let publicKey = try Keychain().createPublicKey(from: privateKey)
        let csr = CertificateSigningRequest()
        guard let csrString = csr.buildCSRAndReturnString(publicKey.data as Data, privateKey: privateKey) else {
            throw CertificateError.errorCreatingSigningRequest
        }
        let requestBody = CertificateCreateRequest(data: .init(attributes: .init(
            certificateType: typeToCreate,
            csrContent: csrString
        )))
        ActionsEnvironment.logger.info("🚀 Creating certificate online...")
        let certificate = try await ActionsEnvironment.service.request(.createCertificate(requestBody: requestBody)).data
        ActionsEnvironment.logger.info("👍 Certificate created online")
        let saveCertificateResult = try saveCertificateInKeychain(certificate: certificate, encryptedCertificatesFolderPath: encryptedCertificatesFolderPath)
        switch saveCertificateResult {
        case .success:
            break
        case .privateKeyForCertificateNotFound:
            ActionsEnvironment.logger.info("🤷🏼 The private key for the certificate was not found in Keychain. This should never happen. Please report it as an issue on Github 🥰")
        case .unknown(let status):
            ActionsEnvironment.logger.info("🤷🏼 An unknown error occurred when adding certificate to Keychain. Please report it as an issue on Github 🥰 and include the error status: \(status)")
        }
    }
}

private func findFirstMatchingCertificateInKeychain(certificates: [Certificate]) throws -> (certificate: Certificate, identity: SecIdentity)? {
    // An identity represents a combination of a private key and a certificate
    var copyResult: CFTypeRef?
    let statusCopyingIdentities = SecItemCopyMatching([
        kSecClass: kSecClassIdentity,
        kSecMatchLimit: kSecMatchLimitAll,
        kSecReturnRef: true,
    ] as NSDictionary, &copyResult)
    guard statusCopyingIdentities == errSecSuccess, let identities = copyResult as? [SecIdentity] else {
        throw CertificateError.errorReadingFromKeychain
    }
    let certificatesBySerialNumber = certificates.reduce(into: [String: Certificate]()) { result, certificate in
        if let serialNumber = certificate.attributes?.serialNumber?.lowercased() {
            result[serialNumber] = certificate
        }
    }
    for identity in identities {
        var certificate: SecCertificate?
        let statusCopyingCertificate = SecIdentityCopyCertificate(identity, &certificate)
        guard statusCopyingCertificate == errSecSuccess, let certificate = certificate else {
            throw CertificateError.errorReadingFromKeychain
        }
        let serialNumber = (SecCertificateCopySerialNumberData(certificate, nil)! as Data).hexadecimalString
        if let certificate = certificatesBySerialNumber[serialNumber] {
            return (certificate: certificate, identity: identity)
        }
    }
    return nil
}

private func exportIdentity(certificateSerialNumber: String, identity: SecIdentity, encryptedCertificatesFolderPath: String) throws {
    let p12Path = "\(encryptedCertificatesFolderPath)/\(certificateSerialNumber).p12"
    guard !FileManager.default.fileExists(atPath: p12Path) else {
        ActionsEnvironment.logger.trace("Certificate and private key is already saved at here: \(p12Path)")
        return
    }
    ActionsEnvironment.logger.info("💾 Saving the certificate and private key...")
    var passphrase: String
    var shouldSavePassphrase: Bool
    if let savedPassphrase = try? Keychain().readP12Passphrase(certificateSerialNumber: certificateSerialNumber) {
        passphrase = savedPassphrase
        shouldSavePassphrase = false
    } else {
        ActionsEnvironment.logger.warning("Enter passphrase for the exported certificate and private key:")
        passphrase = ActionsEnvironment.terminal.getInput(secret: true)
        shouldSavePassphrase = true
    }
    var exportedData: CFData?
    var params = SecItemImportExportKeyParameters()
    params.passphrase = Unmanaged.passRetained(passphrase as CFString)
    let statusExportingIdentity = SecItemExport(identity, .formatPKCS12, [], &params, &exportedData)
    guard statusExportingIdentity == errSecSuccess, let exportedData = exportedData as Data? else {
        throw CertificateError.errorExportingFromKeychain
    }
    try ActionsEnvironment.shell.run("mkdir -p \(encryptedCertificatesFolderPath)")
    let p12Url = URL(fileURLWithPath: p12Path)
    try exportedData.write(to: p12Url)
    ActionsEnvironment.logger.info("👍 Certificate and private key saved at: \(p12Path)")
    if shouldSavePassphrase {
        try savePassphraseInKeychain(passphrase, certificateSerialNumber: certificateSerialNumber)
    }
}

private func savePassphraseInKeychain(_ passphrase: String, certificateSerialNumber: String) throws {
    ActionsEnvironment.logger.info("💾 Saving passphrase in Keychain...")
    try Keychain().saveP12Password(passphrase, certificateSerialNumber: certificateSerialNumber)
    ActionsEnvironment.logger.info("👍 Passphrase saved in Keychain")
}

public enum EnsureCertificatePolicy {
    case readOnly
    case createNewIfMissing
}


#endif
