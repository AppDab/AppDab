public func addAPIKey(_ apiKey: APIKey) throws {
    ActionsEnvironment.logger.info("🔐 Adding API Key to Keychain...")
    do {
        try ActionsEnvironment.keychain.addGenericPassword(forService: "AppDab", password: apiKey.getGenericPassword())
    } catch KeychainError.duplicatePassword {
        throw APIKeyError.duplicateAPIKey
    } catch KeychainError.failedAddingPassword(let status) {
        throw APIKeyError.failedAddingAPIKey(status)
    }
    ActionsEnvironment.logger.info("👍 API Key added to Keychain")
}
