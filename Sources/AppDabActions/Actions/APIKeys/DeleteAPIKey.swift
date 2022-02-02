public func deleteAPIKey(_ apiKey: APIKey) throws {
    ActionsEnvironment.logger.info("🔐 Deleting API Key '\(apiKey.keyId)' from Keychain...")
    try ActionsEnvironment.keychain.deleteGenericPassword(forService: "AppDab", password: apiKey.getGenericPassword())
    ActionsEnvironment.logger.info("👍 API Key deleted from Keychain")
}
