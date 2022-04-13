#if os(macOS)
/**
 Set the build number for a project
 
 - Parameter buildNumber: The build number to set
 - Parameter xcodeProjPath: The path to a specific Xcode project. If this is not specified, it will look in the current directory.
 - Parameter includingInfoPlist: Also update the build number in Info.plist files. Newer Xcode projects don't need this as the files are generated build time.
 - Remark: This uses Apple's `agvtool`.
 */
public func setBuildNumber(_ buildNumber: BuildNumber, xcodeProjPath: String? = nil, includingInfoPlists: Bool = false) throws {
    let value = try buildNumber.getValue()
    let path = getPathContainingXcodeProj(xcodeProjPath)
    ActionsEnvironment.logger.info("✍️ Setting build number to '\(value)'...")
    var command = "xcrun agvtool new-version \(value)"
    if includingInfoPlists {
        command = command + " -all"
    }
    ActionsEnvironment.logger.trace("⚡️ \(command)")
    let output = try ActionsEnvironment.shell.run(command, at: path)
    ActionsEnvironment.logger.info("📔 Output from agvtool:\n\(output)")
}
#endif
