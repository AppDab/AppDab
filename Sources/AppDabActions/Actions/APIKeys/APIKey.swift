import Bagbutik_Core
import Foundation

/// A collection of the required keys and values for an API Key from App Store Connect.
public struct APIKey: Identifiable, Hashable {
    public var id: String { keyId }
    /// The user specified name of the API Key.
    public let name: String
    /// The private key ID from App Store Connect; for example 2X9R4HXF34.
    public let keyId: String
    /// The issuer ID (only for Team keys) from the API Keys page in App Store Connect; for example, 57246542-96fe-1a63-e053-0824d011072a.
    public let issuerId: String?
    /// The contents of the private key from App Store Connect. Starting with `-----BEGIN PRIVATE KEY-----`.
    public let privateKey: String
    /// The generated JWT from the keys.
    public let jwt: JWT

    /**
     Create a new API Key.

     Full documentation for how to get the required keys.
     <https://developer.apple.com/documentation/appstoreconnectapi/creating_api_keys_for_app_store_connect_api>

     - Parameters:
        - name: The user specified name of the API Key.
        - keyId: The private key ID from App Store Connect; for example 2X9R4HXF34.
        - issuerId: The issuer ID (only for Team keys) from the API Keys page in App Store Connect; for example, 57246542-96fe-1a63-e053-0824d011072a.
        - privateKey: The contents of the private key from App Store Connect. Starting with `-----BEGIN PRIVATE KEY-----`.
     - Throws: An error if the private key is invalid.
     */
    public init(name: String, keyId: String, issuerId: String? = nil, privateKey: String) throws {
        self.name = name
        self.keyId = keyId
        self.privateKey = privateKey
        if let issuerId, !issuerId.isEmpty {
            self.issuerId = issuerId
            self.jwt = try .init(keyId: keyId, issuerId: issuerId, privateKey: privateKey)
        } else {
            self.issuerId = nil
            self.jwt = try .init(keyId: keyId, privateKey: privateKey)
        }
    }

    init(password: GenericPassword) throws {
        guard let issuerId = String(data: password.generic, encoding: .utf8),
              let privateKey = String(data: password.value, encoding: .utf8) else {
            throw APIKeyError.invalidAPIKeyFormat
        }
        try self.init(name: password.label,
                      keyId: password.account,
                      issuerId: issuerId,
                      privateKey: privateKey)
    }

    func getGenericPassword() throws -> GenericPassword {
        .init(account: keyId,
              label: name,
              generic: issuerId.map { Data($0.utf8) } ?? Data(),
              value: Data(privateKey.utf8))
    }

    public static func == (lhs: APIKey, rhs: APIKey) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(keyId)
        hasher.combine(issuerId)
        hasher.combine(privateKey)
    }
}
