#if os(macOS)
import Foundation
import XMLCoder

/**
 Upload an exported archive to App Store Connect.
 
 The upload is performed with Apple's `altool` coomand line tool.
 
 - Parameter exportedArchivePath: Path to the exported archive to upload.
 - Parameter appAppleId: The Apple ID for the app, which is being uploaded.
 */
public func uploadExportedArchive(exportedArchivePath: String? = ActionsEnvironment.values.exportedArchivePath,
                                  appAppleId: String? = ActionsEnvironment.settings.appAppleId) throws {
    guard let exportedArchivePath = exportedArchivePath else {
        throw UploadError.exportedArchivePathMissing
    }
    guard let appAppleId = appAppleId else {
        throw UploadError.appAppleIdMissing
    }
    try ActionsEnvironment.altool.upload(exportedArchivePath: exportedArchivePath, appAppleId: appAppleId)
}

#endif
