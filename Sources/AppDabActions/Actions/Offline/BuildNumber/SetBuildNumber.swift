/**
 Set the build number for a project
 
 - Parameter buildNumber: The build number to set
 - Parameter xcodeProjPath: The path to a specific Xcode project. If this is not specified, it will look in the current directory.
 - Remark: This uses Apple's `agvtool`.
 */
public func setBuildNumber(_ buildNumber: BuildNumber, xcodeProjPath: String? = nil) throws {
    let value = try buildNumber.getValue()
    let path = getPathContainingXcodeProj(xcodeProjPath)
    ActionsEnvironment.logger.info("✍️ Setting build number to '\(value)'...")
    let command = "xcrun agvtool new-version -all \(value)"
    ActionsEnvironment.logger.trace("⚡️ \(command)")
    let output = try ActionsEnvironment.shell.run(command, at: path)
    ActionsEnvironment.logger.info("📔 Output from agvtool:\n\(output)")
}
