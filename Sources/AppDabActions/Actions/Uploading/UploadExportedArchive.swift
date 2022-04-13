#if os(macOS)
import Foundation
import XMLCoder

public func uploadExportedArchive(exportedArchivePath: String? = ActionsEnvironment.values.exportedArchivePath, appAppleId: String) throws {
    guard let exportedArchivePath = exportedArchivePath else {
        throw UploadError.exportedArchivePathMissing
    }
    try ActionsEnvironment.altool.upload(exportedArchivePath: exportedArchivePath, appAppleId: appAppleId)
}

#endif
