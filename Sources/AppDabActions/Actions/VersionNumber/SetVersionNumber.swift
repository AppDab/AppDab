#if os(macOS)
/**
 Set the version number for a project
 
 - Parameter version: The version number to set
 - Parameter xcodeProjPath: The path to a specific Xcode project. If this is not specified, it will look in the current directory.
 - Remark: This uses Apple's `agvtool`.
 */
public func setVersionNumber(_ version: String, xcodeProjPath: String? = nil) throws {
    let path = getPathContainingXcodeProj(xcodeProjPath)
    ActionsEnvironment.logger.info("✍️ Setting version number to '\(version)'...")
    let command = "xcrun agvtool new-marketing-version \(version)"
    ActionsEnvironment.logger.trace("⚡️ \(command)")
    let output = try ActionsEnvironment.shell.run(command, at: path)
    ActionsEnvironment.logger.info("📔 Output from agvtool:\n\(output)")
}
#endif
