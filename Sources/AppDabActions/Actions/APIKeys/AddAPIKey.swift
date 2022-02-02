public func addAPIKey(_ apiKey: APIKey) throws {
    ActionsEnvironment.logger.info("🔐 Adding API Key to Keychain...")
    do {
        try ActionsEnvironment.keychain.addGenericPassword(forService: "AppDab", password: apiKey.getGenericPassword())
    } catch let error as KeychainError where error == .duplicatePassword {
        throw APIKeyError.duplicateAPIKey
    }
    ActionsEnvironment.logger.info("👍 API Key added to Keychain")
}
