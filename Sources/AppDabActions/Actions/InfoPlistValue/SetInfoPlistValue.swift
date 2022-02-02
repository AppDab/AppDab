#if os(macOS)
/**
 Set a value for a key in an Info.plist

 - Parameter value: The value to set
 - Parameter key: The key to set the value for
 - Parameter infoPlistPath: The path to a specific Info.plist. If this is not specified, it try to find it by looking for a Xcode project in the current directory.
 */
public func setInfoPlistValue(_ value: Any, forKey key: String, infoPlistPath: String? = nil) throws {
    let path = try infoPlistPath ?? ActionsEnvironment.infoPlist.findInfoPlist()
    let infoPlist = try ActionsEnvironment.infoPlist.loadInfoPlist(at: path)
    ActionsEnvironment.logger.info("✍️ Setting Info.plist value '\(value)' for key '\(key)'...")
    infoPlist[key] = value
    try ActionsEnvironment.infoPlist.saveInfoPlist(infoPlist, at: path)
    ActionsEnvironment.logger.info("👍 Info.plist value updated")
}
#endif
