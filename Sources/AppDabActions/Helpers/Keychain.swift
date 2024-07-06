import Foundation
import Security

public protocol KeychainProtocol {
    func addCertificate(certificate: SecCertificate, named name: String) throws
    func hasCertificate(serialNumber: String) async throws -> Bool
    func hasCertificates(serialNumbers: [String]) throws -> [String: Bool]
    func createPrivateKey(labeled label: String) throws -> SecKey
    func createPublicKey(from privateKey: SecKey) throws -> (key: SecKey, data: Data)
    func getGenericPassword(forService service: String, account: String) throws -> GenericPassword?
    func listGenericPasswords(forService service: String) throws -> [GenericPassword]
    func addGenericPassword(forService service: String, password: GenericPassword) throws
    func updateGenericPassword(forService service: String, password: GenericPassword) throws
    func deleteGenericPassword(forService service: String, password: GenericPassword) throws
}

public struct GenericPassword {
    public let account: String
    public let label: String
    public let generic: Data
    public let value: Data
    
    public init(account: String, label: String, generic: Data, value: Data) {
        self.account = account
        self.label = label
        self.generic = generic
        self.value = value
    }
}

struct Keychain: KeychainProtocol {
    func addCertificate(certificate: SecCertificate, named name: String) throws {
        let addquery: NSDictionary = [kSecClass: kSecClassCertificate,
                                      kSecValueRef: certificate,
                                      kSecAttrLabel: name]
        let addStatus = secItemAdd(addquery, nil)
        guard addStatus == errSecSuccess || addStatus == errSecDuplicateItem else {
            throw AddCertificateToKeychainError.errorAddingCertificateToKeychain(status: addStatus)
        }
    }

    func hasCertificate(serialNumber: String) async throws -> Bool {
        try await withCheckedThrowingContinuation { continuation in
            Task {
                do {
                    var copyResult: CFTypeRef?
                    let statusCopyingIdentities = secItemCopyMatching([
                        kSecClass: kSecClassIdentity,
                        kSecMatchLimit: kSecMatchLimitAll,
                        kSecReturnRef: true,
                    ] as NSDictionary, &copyResult)
                    guard statusCopyingIdentities != errSecItemNotFound else {
                        continuation.resume(returning: false)
                        return
                    }
                    guard statusCopyingIdentities == errSecSuccess, let identities = copyResult as? [SecIdentity] else {
                        throw CertificateError.errorReadingFromKeychain(statusCopyingIdentities)
                    }
                    let serialNumbersInKeychain: [String] = try identities.compactMap { identity in
                        var certificate: SecCertificate?
                        let statusCopyingCertificate = secIdentityCopyCertificate(identity, &certificate)
                        guard statusCopyingCertificate == errSecSuccess, let certificate else {
                            throw KeychainError.errorReadingFromKeychain(statusCopyingCertificate)
                        }
                        return (secCertificateCopySerialNumberData(certificate, nil)! as Data).hexadecimalString.lowercased()
                    }
                    continuation.resume(returning: serialNumbersInKeychain.contains(serialNumber.lowercased()))
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func hasCertificates(serialNumbers: [String]) throws -> [String: Bool] {
        var copyResult: CFTypeRef?
        let statusCopyingIdentities = secItemCopyMatching([
            kSecClass: kSecClassIdentity,
            kSecMatchLimit: kSecMatchLimitAll,
            kSecReturnRef: true,
        ] as NSDictionary, &copyResult)
        if statusCopyingIdentities == errSecItemNotFound {
            return serialNumbers.reduce(into: [:]) { result, serialNumber in
                result[serialNumber] = false
            }
        }
        guard statusCopyingIdentities == errSecSuccess, let identities = copyResult as? [SecIdentity] else {
            throw CertificateError.errorReadingFromKeychain(statusCopyingIdentities)
        }
        let serialNumbersInKeychain: [String] = try identities.compactMap { identity in
            var certificate: SecCertificate?
            let statusCopyingCertificate = secIdentityCopyCertificate(identity, &certificate)
            guard statusCopyingCertificate == errSecSuccess, let certificate else {
                throw KeychainError.errorReadingFromKeychain(statusCopyingCertificate)
            }
            return (secCertificateCopySerialNumberData(certificate, nil)! as Data).hexadecimalString.lowercased()
        }
        return serialNumbers.reduce(into: [:]) { result, serialNumber in
            result[serialNumber] = serialNumbersInKeychain.contains(serialNumber.lowercased())
        }
    }

    func createPrivateKey(labeled label: String) throws -> SecKey {
        let tag = label.data(using: .utf8)!
        let parameters: NSDictionary =
            [kSecAttrKeyType: kSecAttrKeyTypeRSA,
             kSecAttrKeySizeInBits: 2048,
             kSecAttrLabel: label,
             kSecPrivateKeyAttrs: [
                 kSecAttrIsPermanent: true,
                 kSecAttrApplicationTag: tag,
             ]]
        var error: Unmanaged<CFError>?
        guard let privateKey = secKeyCreateRandomKey(parameters, &error) else {
            throw error!.takeRetainedValue() as Error
        }
        return privateKey
    }

    func createPublicKey(from privateKey: SecKey) throws -> (key: SecKey, data: Data) {
        guard let publicKey = secKeyCopyPublicKey(privateKey) else {
            throw CreateCertificateError.errorCreatingPublicKey
        }
        var error: Unmanaged<CFError>?
        guard let publicKeyData = secKeyCopyExternalRepresentation(publicKey, &error) else {
            throw error!.takeRetainedValue() as Error
        }
        return (key: publicKey, data: publicKeyData as Data)
    }

    func getGenericPassword(forService service: String, account: String) throws -> GenericPassword? {
        try listGenericPasswords(forService: service, account: account).first
    }

    func listGenericPasswords(forService service: String) throws -> [GenericPassword] {
        try listGenericPasswords(forService: service, account: nil)
    }

    private func listGenericPasswords(forService service: String, account: String? = nil) throws -> [GenericPassword] {
        let query: NSMutableDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecMatchLimit: kSecMatchLimitAll,
            kSecReturnAttributes: true,
            kSecReturnData: true,
        ]
        query.addEntries(from: Self.dataProtectionAttributes)
        if let account {
            query[kSecAttrAccount] = account
        }
        var items: CFTypeRef?
        let status = secItemCopyMatching(query, &items)
        guard status != errSecItemNotFound else { return [] }
        guard status == errSecSuccess, let items = items as? [Any] else {
            throw KeychainError.errorReadingFromKeychain(status)
        }
        return try items.map { item -> GenericPassword in
            guard let item = item as? [String: Any],
                  let label = item[kSecAttrLabel as String] as? String,
                  let account = item[kSecAttrAccount as String] as? String,
                  let generic = item[kSecAttrGeneric as String] as? Data,
                  let value = item[kSecValueData as String] as? Data else {
                throw KeychainError.malformedPasswordData
            }
            return GenericPassword(account: account, label: label, generic: generic, value: value)
        }
    }

    func addGenericPassword(forService service: String, password: GenericPassword) throws {
        let query: NSMutableDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: password.account,
            kSecAttrLabel: password.label,
            kSecAttrService: service,
            kSecAttrGeneric: password.generic,
            kSecValueData: password.value
        ]
        query.addEntries(from: Self.dataProtectionAttributes)
        let status = secItemAdd(query, nil)
        guard status != errSecDuplicateItem else {
            throw KeychainError.duplicatePassword
        }
        guard status == errSecSuccess else {
            throw KeychainError.failedAddingPassword(status)
        }
    }

    func updateGenericPassword(forService service: String, password: GenericPassword) throws {
        let query: NSMutableDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: password.account,
            kSecAttrService: service,
        ]
        query.addEntries(from: Self.dataProtectionAttributes)
        let attributesToUpdate: NSMutableDictionary = [
            kSecAttrLabel: password.label,
            kSecAttrGeneric: password.generic,
            kSecValueData: password.value,
        ]
        attributesToUpdate.addEntries(from: Self.dataProtectionAttributes)
        let status = secItemUpdate(query, attributesToUpdate)
        guard status == errSecSuccess else {
            throw KeychainError.failedUpdatingPassword
        }
    }

    func deleteGenericPassword(forService service: String, password: GenericPassword) throws {
        let query: NSMutableDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: password.account,
            kSecAttrService: service,
        ]
        query.addEntries(from: Self.dataProtectionAttributes)
        let status = secItemDelete(query)
        guard status == errSecSuccess else {
            throw KeychainError.failedDeletingPassword
        }
    }

    private static let dataProtectionAttributes: [AnyHashable: Any] = [
        kSecUseDataProtectionKeychain: true,
        kSecAttrAccessGroup: "R7YA4RGA8U.app.AppDab.AppDab",
        kSecAttrSynchronizable: true,
    ]

    var secItemCopyMatching = SecItemCopyMatching
    var secItemAdd = SecItemAdd
    var secItemUpdate = SecItemUpdate
    var secItemDelete = SecItemDelete
    var secIdentityCopyCertificate = SecIdentityCopyCertificate
    var secCertificateCopySerialNumberData = SecCertificateCopySerialNumberData
    var secKeyCreateRandomKey = SecKeyCreateRandomKey
    var secKeyCopyPublicKey = SecKeyCopyPublicKey
    var secKeyCopyExternalRepresentation = SecKeyCopyExternalRepresentation
    var secPKCS12Import = SecPKCS12Import
    var dataLoader = Data.init(contentsOf:options:)

    // MARK: - The following should not be used anymore

    private static func getService(forSerialNumber serialNumber: String) -> String {
        "AppDab certificate \(serialNumber)"
    }

    func readP12Passphrase(certificateSerialNumber serialNumber: String) throws -> String {
        let query: NSDictionary = [kSecClass: kSecClassGenericPassword,
                                   kSecAttrService: Keychain.getService(forSerialNumber: serialNumber),
                                   kSecMatchLimit: kSecMatchLimitOne,
                                   kSecReturnAttributes: true,
                                   kSecReturnData: true]
        var item: CFTypeRef?
        let status = secItemCopyMatching(query, &item)
        guard status != errSecItemNotFound else { throw KeychainError.noPasswordFound }
        guard status == errSecSuccess,
              let item = item as? NSDictionary,
              let passwordData = item[kSecValueData] as? Data,
              let password = String(data: passwordData, encoding: String.Encoding.utf8)
        else {
            throw KeychainError.unknown(status: status)
        }
        return password
    }

    func saveP12Password(_ password: String, certificateSerialNumber serialNumber: String) throws {
        let passwordData = password.data(using: String.Encoding.utf8)!
        let addAttributes: NSDictionary = [kSecClass: kSecClassGenericPassword,
                                           kSecAttrService: Keychain.getService(forSerialNumber: serialNumber),
                                           kSecValueData: passwordData]
        let addStatus = secItemAdd(addAttributes, nil)
        guard addStatus != errSecDuplicateItem else {
            let query: NSDictionary = [kSecClass: kSecClassGenericPassword,
                                       kSecAttrService: Keychain.getService(forSerialNumber: serialNumber)]
            let attributesToUpdate: NSDictionary = [kSecValueData: passwordData]
            let updateStatus = secItemUpdate(query, attributesToUpdate as CFDictionary)
            guard updateStatus == errSecSuccess else { throw KeychainError.failedAddingPassword(updateStatus) }
            return
        }
        guard addStatus == errSecSuccess else { throw KeychainError.failedAddingPassword(addStatus) }
    }

    func importPCKS12(atPath p12Path: String, passphrase: String) throws {
        let data = try dataLoader(URL(fileURLWithPath: p12Path), []) as CFData
        let options = [kSecImportExportPassphrase: passphrase] as CFDictionary
        var rawItems: CFArray?
        let p12ImportStatus = secPKCS12Import(data, options, &rawItems)
        guard p12ImportStatus != errSecAuthFailed, p12ImportStatus != errSecPkcs12VerifyFailure else { throw KeychainError.wrongPassphraseForP12 }
        guard p12ImportStatus == errSecSuccess else { throw KeychainError.errorImportingP12 }
    }
}

public enum KeychainError: ActionError, Equatable {
    case errorReadingFromKeychain(OSStatus)
    case malformedPasswordData
    case noPasswordFound
    case failedAddingPassword(OSStatus)
    case duplicatePassword
    case failedUpdatingPassword
    case failedDeletingPassword
    case wrongPassphraseForP12
    case errorImportingP12
    case unknown(status: OSStatus)

    public var description: String {
        switch self {
        case .errorReadingFromKeychain(let status):
            "Could not read from Keychain (OSStatus: \(status))"
        case .malformedPasswordData:
            "The password is missing data"
        case .noPasswordFound:
            "No password found in Keychain"
        case .failedAddingPassword:
            "Could not add password to Keychain"
        case .duplicatePassword:
            "Password already in Keychain"
        case .failedUpdatingPassword:
            "Could not update password in Keychain"
        case .failedDeletingPassword:
            "Could not delete password from Keychain"
        case .wrongPassphraseForP12:
            "Wrong passphrase for encrypted certificate and private key"
        case .errorImportingP12:
            "Could not import certificate and private key"
        case .unknown(let status):
            "Unknown error occurred when interacting with Keychain (OSStatus: \(status))"
        }
    }
}
