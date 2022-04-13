#if os(macOS)
/**
 Increment the build number for a project
 
 - Parameter xcodeProjPath: The path to a specific Xcode project. If this is not specified, it will look in the current directory.
 - Parameter includingInfoPlist: Also update the build number in Info.plist files. Newer Xcode projects don't need this as the files are generated build time.
 - Remark: This uses Apple's `agvtool`.
 */
public func incrementBuildNumber(xcodeProjPath: String? = nil, includingInfoPlists: Bool = false) throws {
    let path = getPathContainingXcodeProj(xcodeProjPath)
    ActionsEnvironment.logger.info("✍️ Incrementing build number...")
    var command = "xcrun agvtool next-version"
    if includingInfoPlists {
        command = command + " -all"
    }
    ActionsEnvironment.logger.trace("⚡️ \(command)")
    let output = try ActionsEnvironment.shell.run(command, at: path)
    ActionsEnvironment.logger.info("📔 Output from agvtool:\n\(output)")
}
#endif
