/**
 Increment the version number for a project
 
 - Parameter versionBump: The method to bump the version
 - Parameter xcodeProjPath: The path to a specific Xcode project. If this is not specified, it will look in the current directory.
 - Remark: This uses Apple's `agvtool`.
 */
public func incrementVersionNumber(_ versionBump: VersionBump, xcodeProjPath: String? = nil) throws {
    let currentVersionNumber = try getVersionNumber(xcodeProjPath: xcodeProjPath)
    let path = getPathContainingXcodeProj(xcodeProjPath)
    let bumpedVersion = try versionBump.bumpVersion(currentVersionNumber)
    ActionsEnvironment.logger.info("✍️ Incrementing \(versionBump.rawValue) version (\(currentVersionNumber) -> \(bumpedVersion))...")
    let command = "xcrun agvtool new-marketing-version \(bumpedVersion)"
    ActionsEnvironment.logger.trace("⚡️ \(command)")
    let output = try ActionsEnvironment.shell.run(command, at: path)
    ActionsEnvironment.logger.info("📔 Output from agvtool:\n\(output)")
}
