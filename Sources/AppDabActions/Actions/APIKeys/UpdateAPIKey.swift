/**
 Update an API Key in Keychain

 - Parameters:
    - apiKey: The API Key to update in Keychain.
    - keyId: The key id of the saved API Key to update in Keychain.
 */
public func updateAPIKey(_ apiKey: APIKey, forKeyId keyId: String) throws {
    ActionsEnvironment.logger.info("🔐 Updating API Key '\(keyId)' in Keychain...")
    try ActionsEnvironment.keychain.updateGenericPassword(
        forService: "AppDab", password: apiKey.getGenericPassword(),
        searchInDataProtectionKeychain: true,
        updateInDataProtectionKeychain: true
    )
    ActionsEnvironment.logger.info("👍 API Key updated in Keychain")
}
