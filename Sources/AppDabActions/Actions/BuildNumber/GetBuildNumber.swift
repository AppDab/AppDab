#if os(macOS)
/**
 Get the current build number for a project
 
 - Parameter xcodeProjPath: The path to a specific Xcode project. If this is not specified, it will look in the current directory.
 - Returns: The current build number
 - Remark: This uses Apple's `agvtool`.
 */
public func getBuildNumber(xcodeProjPath: String? = nil) throws -> String {
    let path = getPathContainingXcodeProj(xcodeProjPath)
    ActionsEnvironment.logger.info("🔍 Reading build number...")
    let command = "xcrun agvtool what-version -terse"
    ActionsEnvironment.logger.trace("⚡️ \(command)")
    let output = try ActionsEnvironment.shell.run(command, at: path)
    ActionsEnvironment.logger.info("👍 Got build number: \(output)")
    return output
}
#endif
