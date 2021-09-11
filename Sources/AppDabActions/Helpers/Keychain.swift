import Foundation
import Security

internal protocol KeychainProtocol {
    func addCertificate(certificate: SecCertificate, named name: String) throws
    func createPrivateKey(labeled label: String) throws -> SecKey
    func createPublicKey(from privateKey: SecKey) throws -> (key: SecKey, data: Data)
}

internal struct Keychain: KeychainProtocol {
    func addCertificate(certificate: SecCertificate, named name: String) throws {
        let addquery: [String: Any] = [kSecClass as String: kSecClassCertificate,
                                       kSecValueRef as String: certificate,
                                       kSecAttrLabel as String: name]
        let addStatus = secItemAdd(addquery as CFDictionary, nil)
        guard addStatus == errSecSuccess || addStatus == errSecDuplicateItem else {
            throw AddCertificateToKeychainError.errorAddingCertificateToKeychain(status: addStatus)
        }
    }

    func createPrivateKey(labeled label: String) throws -> SecKey {
        let tag = label.data(using: .utf8)!
        let parameters: [String: Any] =
            [kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
             kSecAttrKeySizeInBits as String: 2048,
             kSecAttrLabel as String: label,
             kSecPrivateKeyAttrs as String: [
                 kSecAttrIsPermanent as String: true,
                 kSecAttrApplicationTag as String: tag,
             ]]
        var error: Unmanaged<CFError>?
        guard let privateKey = secKeyCreateRandomKey(parameters as CFDictionary, &error) else {
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

    internal var secItemCopyMatching = SecItemCopyMatching
    internal var secItemAdd = SecItemAdd
    internal var secItemUpdate = SecItemUpdate
    internal var secKeyCreateRandomKey = SecKeyCreateRandomKey
    internal var secKeyCopyPublicKey = SecKeyCopyPublicKey
    internal var secKeyCopyExternalRepresentation = SecKeyCopyExternalRepresentation
    internal var secPKCS12Import = SecPKCS12Import
    internal var dataLoader = Data.init(contentsOf:options:)

    // MARK: - The following should not be used anymore

    private static func getService(forSerialNumber serialNumber: String) -> String {
        return "AppDab certificate \(serialNumber)"
    }

    internal func readP12Passphrase(certificateSerialNumber serialNumber: String) throws -> String {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrService as String: Keychain.getService(forSerialNumber: serialNumber),
                                    kSecMatchLimit as String: kSecMatchLimitOne,
                                    kSecReturnAttributes as String: true,
                                    kSecReturnData as String: true]
        var item: CFTypeRef?
        let status = secItemCopyMatching(query as CFDictionary, &item)
        guard status != errSecItemNotFound else { throw KeychainError.noPasswordFound }
        guard status == errSecSuccess,
              let item = item as? [String: Any],
              let passwordData = item[kSecValueData as String] as? Data,
              let password = String(data: passwordData, encoding: String.Encoding.utf8)
        else {
            throw KeychainError.unknown(status: status)
        }
        return password
    }

    internal func saveP12Passphrase(_ password: String, certificateSerialNumber serialNumber: String) throws {
        let passwordData = password.data(using: String.Encoding.utf8)!
        let addAttributes: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                            kSecAttrService as String: Keychain.getService(forSerialNumber: serialNumber),
                                            kSecValueData as String: passwordData]
        let addStatus = secItemAdd(addAttributes as CFDictionary, nil)
        guard addStatus != errSecDuplicateItem else {
            let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                        kSecAttrService as String: Keychain.getService(forSerialNumber: serialNumber)]
            let attributesToUpdate: [String: Any] = [kSecValueData as String: passwordData]
            let updateStatus = secItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
            guard updateStatus == errSecSuccess else { throw KeychainError.failedAddingPassword }
            return
        }
        guard addStatus == errSecSuccess else { throw KeychainError.failedAddingPassword }
    }

    internal func importPCKS12(atPath p12Path: String, passphrase: String) throws {
        let data = try dataLoader(URL(fileURLWithPath: p12Path), []) as CFData
        let options = [kSecImportExportPassphrase: passphrase] as CFDictionary
        var rawItems: CFArray?
        let p12ImportStatus = secPKCS12Import(data, options, &rawItems)
        guard p12ImportStatus != errSecAuthFailed, p12ImportStatus != errSecPkcs12VerifyFailure else { throw KeychainError.wrongPassphraseForP12 }
        guard p12ImportStatus == errSecSuccess else { throw KeychainError.errorImportingP12 }
    }
}

internal enum KeychainError: ActionError, Equatable {
    case noPasswordFound
    case failedAddingPassword
    case wrongPassphraseForP12
    case errorImportingP12
    case unknown(status: OSStatus)

    internal var description: String {
        switch self {
        case .noPasswordFound:
            return "No password found in Keychain"
        case .failedAddingPassword:
            return "Could not add passphrase to Keychain"
        case .wrongPassphraseForP12:
            return "Wrong passphrase for encrypted certificate and private key"
        case .errorImportingP12:
            return "Could not import certificate and private key"
        case .unknown(let status):
            return "Unknown error occurred when interacting with Keychain (OSStatus: \(status))"
        }
    }
}
