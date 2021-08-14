/**
 Increment the build number for a project
 
 - Parameter xcodeProjPath: The path to a specific Xcode project. If this is not specified, it will look in the current directory.
 - Remark: This uses Apple's `agvtool`.
 */
public func incrementBuildNumber(xcodeProjPath: String? = nil) throws {
    let path = getPathContainingXcodeProj(xcodeProjPath)
    ActionsEnvironment.logger.info("✍️ Incrementing build number...")
    let command = "xcrun agvtool next-version -all"
    ActionsEnvironment.logger.trace("⚡️ \(command)")
    let output = try ActionsEnvironment.shell.run(command, at: path)
    ActionsEnvironment.logger.info("📔 Output from agvtool:\n\(output)")
}
