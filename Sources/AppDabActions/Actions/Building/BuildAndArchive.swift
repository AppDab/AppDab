#if os(macOS)
/**
 Build and archive (.xcarchive) a scheme in a project
 
 - Parameter xcodeProjPath: The path to a specific Xcode project. If this is not specified, it will look in the current directory.
 - Parameter schemeName: The name of the scheme to build and archive. If this is not specified, it will look for a scheme matching the name of the project or let the user select from a list.
 - Postcondition: If the build and archive is successful, the path to the .xcarchive is saved in the shared ``Values/xcarchivePath``.
 */
public func buildAndArchive(xcodeProjPath: String? = nil, schemeName: String? = nil) throws {
    ActionsEnvironment.logger.info("📦 Building and archiving...")
    let path = getPathContainingXcodeProj(xcodeProjPath)
    let scheme = try schemeName ?? ActionsEnvironment.xcodebuild.findSchemeName(at: path)
    let dateTime = Formatters.archiveDateTimeFormatter.string(from: ActionsEnvironment.getCurrentDate())
    let archiveFileName = "\(scheme) \(dateTime).xcarchive"
    try ActionsEnvironment.shell.run("xcodebuild archive -scheme '\(scheme)' -archivePath '\(archiveFileName)'", outputCallback: {
        guard let parsedLine = ActionsEnvironment.parseXcodebuildOutput($0, true), parsedLine != "" else { return }
        ActionsEnvironment.logger.info("\(parsedLine)")
    })
    ActionsEnvironment.logger.info("🚚 Moving archive to Xcode's Archives folder...")
    let dateFolderName = Formatters.dateFolderFormatter.string(from: ActionsEnvironment.getCurrentDate())
    try ActionsEnvironment.shell.run("mkdir -p ~/Library/Developer/Xcode/Archives/\(dateFolderName)")
    try ActionsEnvironment.shell.run("mv '\(archiveFileName)' ~/Library/Developer/Xcode/Archives/\(dateFolderName)")
    let archivePath = "~/Library/Developer/Xcode/Archives/\(dateFolderName)/\(archiveFileName)"
    ActionsEnvironment.logger.info("🎉 Project built and archived. The archive is available in Xcode's Organizer")
    ActionsEnvironment.logger.trace("The archive is here: \(archivePath)")
    ActionsEnvironment.values.xcarchivePath = archivePath
}
#endif
