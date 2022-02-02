#if os(macOS)
/**
 Export an archive (.xcarchive) to a distributable package (.ipa)
 
 - Parameter archivePath: The path to the archive to export. If this is not specified, it will take the path saved in the shared ``Values/xcarchivePath``.
 - Parameter exportPath: The path of the folder to contain the exported package. Default is the current directory.
 - Parameter exportOptionsPlist: The path to the [export options plist](https://developer.apple.com/library/archive/technotes/tn2339/_index.html#//apple_ref/doc/uid/DTS40014588-CH1-WHAT_KEYS_CAN_I_PASS_TO_THE_EXPORTOPTIONSPLIST_FLAG_). Default is `ExportOptions.plist`.
 - Postcondition: If the export is successful, the path to the exported package is saved in the shared ``Values/ipaPath``.
 */
public func exportArchive(archivePath: String? = nil, exportPath: String = ".", exportOptionsPlist: String = "ExportOptions.plist") throws {
    ActionsEnvironment.logger.info("🎁 Exporting archive...")
    guard let archivePath = archivePath ?? ActionsEnvironment.values.xcarchivePath else {
        throw XcodebuildError.archivePathMissing
    }
    try ActionsEnvironment.shell.run("xcodebuild -exportArchive -archivePath '\(archivePath)' -exportPath '\(exportPath)' -exportOptionsPlist '\(exportOptionsPlist)'", outputCallback: {
        guard let parsedLine = ActionsEnvironment.parseXcodebuildOutput($0, true), parsedLine != "" else { return }
        ActionsEnvironment.logger.info("\(parsedLine)")
    })
    ActionsEnvironment.logger.info("🎉 Archive exported")
    let allItemsInExportPath = try ActionsEnvironment.fileManager.contentsOfDirectory(atPath: exportPath)
    guard let exportedArchiveFileName = allItemsInExportPath.first(where: { $0.hasSuffix(".ipa") }) else {
        throw XcodebuildError.exportedArchiveNotFound
    }
    let exportedArchivePath = "\(exportPath)/\(exportedArchiveFileName)"
    ActionsEnvironment.logger.trace("The exported archive is here: \(exportedArchivePath)")
    ActionsEnvironment.values.ipaPath = exportedArchivePath
}
#endif
