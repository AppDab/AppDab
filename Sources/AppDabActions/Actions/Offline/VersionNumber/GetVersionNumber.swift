#if os(macOS)
/**
 Get the current version number for a project
 
 - Parameter xcodeProjPath: The path to a specific Xcode project. If this is not specified, it will look in the current directory.
 - Returns: The current version number
 - Remark: This uses Apple's `agvtool`.
 */
public func getVersionNumber(xcodeProjPath: String? = nil) throws -> String {
    let path = getPathContainingXcodeProj(xcodeProjPath)
    ActionsEnvironment.logger.info("🔍 Reading version number...")
    let command = "xcrun agvtool what-marketing-version -terse1"
    ActionsEnvironment.logger.trace("⚡️ \(command)")
    let output = try ActionsEnvironment.shell.run(command, at: path)
    ActionsEnvironment.logger.info("👍 Got version number: \(output)")
    return output
}
#endif
