/**
 Add an API Key to Keychain
 
 The API Key is saved as a generic password in Keychain with "AppDab" as service, key id as account and the name as label.
 
 - Parameters:
    - apiKey: The API Key to add to Keychain.
 */
public func addAPIKey(_ apiKey: APIKey) throws {
    ActionsEnvironment.logger.info("🔐 Adding API Key to Keychain...")
    do {
        try ActionsEnvironment.keychain.addGenericPassword(forService: "AppDab", password: apiKey.getGenericPassword())
    } catch KeychainError.duplicatePassword {
        throw APIKeyError.duplicateAPIKey
    } catch let KeychainError.failedAddingPassword(status) {
        throw APIKeyError.failedAddingAPIKey(status)
    }
    ActionsEnvironment.logger.info("👍 API Key added to Keychain")
}
