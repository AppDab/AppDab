public func updateAPIKey(_ apiKey: APIKey, forKeyId keyId: String) throws {
    ActionsEnvironment.logger.info("🔐 Updating API Key '\(keyId)' in Keychain...")
    try ActionsEnvironment.keychain.updateGenericPassword(forService: "AppDab", account: keyId, password: apiKey.getGenericPassword())
    ActionsEnvironment.logger.info("👍 API Key updated in Keychain")
}
