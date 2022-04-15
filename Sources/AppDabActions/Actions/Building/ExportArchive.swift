#if os(macOS)
/**
 Export an archive (.xcarchive) to a distributable package (.ipa or .pkg)

 - Parameter archivePath: The path to the archive to export. If this is not specified, it will take the path saved in the shared ``Values/xcarchivePath``.
 - Parameter exportPath: The path of the folder to contain the exported archive.
 - Parameter exportOptionsPlistPath: The path to the [export options plist](https://developer.apple.com/library/archive/technotes/tn2339/_index.html#//apple_ref/doc/uid/DTS40014588-CH1-WHAT_KEYS_CAN_I_PASS_TO_THE_EXPORTOPTIONSPLIST_FLAG_).
 - Postcondition: If the export is successful, the path to the exported package is saved in the shared ``Values/exportedArchivePath``.
 - Returns: The path to the exported archive
 */
@discardableResult
public func exportArchive(archivePath: String? = ActionsEnvironment.values.xcarchivePath,
                          exportPath: String = ActionsEnvironment.settings.exportPath,
                          exportOptionsPlistPath: String = ActionsEnvironment.settings.exportOptionsPlistPath)
    throws -> String {
    ActionsEnvironment.logger.info("🎁 Exporting archive...")
    guard let archivePath = archivePath else {
        throw XcodebuildError.archivePathMissing
    }
    try ActionsEnvironment.shell.run("xcodebuild -exportArchive -archivePath '\(archivePath)' -exportPath '\(exportPath)' -exportOptionsPlist '\(exportOptionsPlistPath)'", outputCallback: {
        guard let parsedLine = ActionsEnvironment.parseXcodebuildOutput($0), parsedLine != "" else { return }
        ActionsEnvironment.logger.info("\(parsedLine)")
    })
    ActionsEnvironment.logger.info("🎉 Archive exported")
    let allItemsInExportPath = try ActionsEnvironment.fileManager.contentsOfDirectory(atPath: exportPath)
    guard let exportedArchiveFileName = allItemsInExportPath.first(where: { $0.hasSuffix(".ipa") || $0.hasSuffix(".pkg") }) else {
        throw XcodebuildError.exportedArchiveNotFound
    }
    let exportedArchivePath = "\(exportPath)/\(exportedArchiveFileName)"
    ActionsEnvironment.logger.trace("The exported archive is here: \(exportedArchivePath)")
    ActionsEnvironment.values.exportedArchivePath = exportedArchivePath
    return exportedArchivePath
}
#endif
