import Foundation
import Security

/**
 Get an API Key from Keychain by key ID.

 - Returns: The API Key with the key ID, if it was found in Keychain.
 */
@discardableResult
public func getAPIKey(withId keyId: String) throws -> APIKey {
    ActionsEnvironment.logger.info("🔐 Getting API Key with id '\(keyId)' from Keychain...")
    let apiKey: APIKey? = try ActionsEnvironment.keychain.getGenericPassword(forService: "AppDab", account: keyId)
        .map {
            guard let apiKey = try? APIKey(password: $0)
            else { throw APIKeyError.invalidAPIKeyFormat }
            return apiKey
        }
    guard let apiKey = apiKey else {
        throw APIKeyError.apiKeyNotInKeychain(keyId)
    }
    ActionsEnvironment.logger.info("👍 Got API Key: \(apiKey.name) (\(apiKey.keyId))")
    return apiKey
}
