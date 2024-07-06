/**
 Delete an API Key from Keychain
 
 - Parameters:
    - apiKey: The API Key to delete from Keychain.
 */
public func deleteAPIKey(_ apiKey: APIKey) throws {
    ActionsEnvironment.logger.info("🔐 Deleting API Key '\(apiKey.keyId)' from Keychain...")
    try ActionsEnvironment.keychain.deleteGenericPassword(forService: "AppDab", password: apiKey.getGenericPassword())
    ActionsEnvironment.logger.info("👍 API Key deleted from Keychain")
}
