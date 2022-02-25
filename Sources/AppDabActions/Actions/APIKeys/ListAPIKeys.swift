import Foundation
import Security

/**
 List all API Key in Keychain.

 - Returns: An array of the API Keys in Keychain.
 */
@discardableResult
public func listAPIKeys() throws -> [APIKey] {
    ActionsEnvironment.logger.info("🔐 Loading list of API Keys from Keychain...")
    let passwords = try ActionsEnvironment.keychain.listGenericPasswords(forService: "AppDab")
    let apiKeys = try passwords.map { password -> APIKey in
        guard let apiKey = try? APIKey(password: password)
        else { throw APIKeyError.invalidAPIKeyFormat }
        return apiKey
    }
    ActionsEnvironment.logger.info("👍 API Keys loaded")
    apiKeys.forEach { apiKey in
        ActionsEnvironment.logger.info(" ◦ \(apiKey.name) (\(apiKey.keyId))")
    }
    return apiKeys
}
