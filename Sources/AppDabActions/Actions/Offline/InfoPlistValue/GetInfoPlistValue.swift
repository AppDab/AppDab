#if os(macOS)
/**
 Get a value for a key in an Info.plist
 
 - Parameter key: The key to get the value for
 - Parameter infoPlistPath: The path to a specific Info.plist. If this is not specified, it try to find it by looking for a Xcode project in the current directory.
 - Returns: The value for the key
 */
public func getInfoPlistValue<T>(forKey key: String, infoPlistPath: String? = nil) throws -> T {
    let path = try infoPlistPath ?? ActionsEnvironment.infoPlist.findInfoPlist()
    let infoPlist = try ActionsEnvironment.infoPlist.loadInfoPlist(at: path)
    ActionsEnvironment.logger.info("🔍 Reading Info.plist value for key '\(key)'...")
    guard let value = infoPlist.object(forKey: key) as? T else {
        throw InfoPlistError.wrongTypeForKey(key: key, path: path)
    }
    ActionsEnvironment.logger.info("👍 Got Info.plist value: \(value)")
    return value
}
#endif
