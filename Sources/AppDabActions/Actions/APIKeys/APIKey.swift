import Bagbutik

public struct APIKey: Identifiable, Hashable {
    public var id: String { keyId }
    public let name: String
    public let keyId: String
    public let issuerId: String
    public let privateKey: String
    public let jwt: JWT

    public init(name: String, keyId: String, issuerId: String, privateKey: String) throws {
        self.name = name
        self.keyId = keyId
        self.issuerId = issuerId
        self.privateKey = privateKey
        self.jwt = try .init(keyId: keyId, issuerId: issuerId, privateKey: privateKey)
    }
    
    internal init(password: GenericPassword) throws {
        guard let issuerId = String(data: password.generic, encoding: .utf8),
              let privateKey = String(data: password.value, encoding: .utf8) else {
            throw APIKeyError.invalidAPIKeyFormat
        }
        try self.init(name: password.label,
                      keyId: password.account,
                      issuerId: issuerId,
                      privateKey: privateKey)
    }

    internal func getGenericPassword() throws -> GenericPassword {
        guard let generic = issuerId.data(using: .utf8),
              let value = privateKey.data(using: .utf8) else {
            throw APIKeyError.invalidAPIKeyFormat
        }
        return .init(account: keyId, label: name, generic: generic, value: value)
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
