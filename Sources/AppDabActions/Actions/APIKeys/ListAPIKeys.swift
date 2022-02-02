import Foundation
import Security

@discardableResult
public func listAPIKeys() throws -> [APIKey] {
    ActionsEnvironment.logger.info("🔐 Loading list of API Keys from Keychain...")
    let apiKeys: [APIKey]
    if let name = ProcessInfo.processInfo.environment["NAME"],
       let keyId = ProcessInfo.processInfo.environment["KEY_ID"],
       let issuerId = ProcessInfo.processInfo.environment["ISSUER_ID"],
       let privateKey = ProcessInfo.processInfo.environment["PRIVATE_KEY"] {
        apiKeys = [try! APIKey(name: name, keyId: keyId, issuerId: issuerId, privateKey: privateKey)]
    } else {
        let passwords = try ActionsEnvironment.keychain.listGenericPasswords(forService: "AppDab")
        apiKeys = try passwords.map { password in
            guard let apiKey = try? APIKey(password: password)
            else { throw APIKeyError.invalidAPIKeyFormat }
            return apiKey
        }
    }
    ActionsEnvironment.logger.info("👍 API Keys loaded")
    apiKeys.forEach { apiKey in
        ActionsEnvironment.logger.info(" ◦ \(apiKey.name) (\(apiKey.keyId))")
    }
    return apiKeys
}
