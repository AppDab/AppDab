/// Migrate the API Keys from the file based Keychain to the data protection Keychain
public func migrateAPIKeysToDataProtectionKeychain() throws {
    ActionsEnvironment.logger.info("🔐 Looking for API Keys in the data protection Keychain...")
    let migratedGenericPassword = try ActionsEnvironment.keychain.listGenericPasswords(forService: "AppDab", useDataProtectionKeychain: true)
    guard migratedGenericPassword.count == 0 else {
        ActionsEnvironment.logger.info("👍 All API Keys are migrated to the data protection Keychain")
        return
    }
    ActionsEnvironment.logger.info("🤷 No API Keys found")
    ActionsEnvironment.logger.info("🔐 Looking for API Keys in the file based Keychain...")
    let unmigratedGenericPasswords = try ActionsEnvironment.keychain.listGenericPasswords(forService: "AppDab", useDataProtectionKeychain: false)
    if unmigratedGenericPasswords.count > 0 {
        ActionsEnvironment.logger.info("😮 Found \(unmigratedGenericPasswords.count) API Keys not migrated yet")
        ActionsEnvironment.logger.info("🚚 Migrating API Keys to data protection Keychain...")
        try unmigratedGenericPasswords.forEach { genericPassword in
            try ActionsEnvironment.keychain.updateGenericPassword(
                forService: "AppDab", password: genericPassword,
                searchInDataProtectionKeychain: false,
                updateInDataProtectionKeychain: true)
        }
    }
    ActionsEnvironment.logger.info("👍 All API Keys are migrated to the data protection Keychain")
}
