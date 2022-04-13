#if os(macOS)
import Foundation
import XMLCoder

public func validateExportedArchive(exportedArchivePath: String? = ActionsEnvironment.values.exportedArchivePath) throws {
    guard let exportedArchivePath = exportedArchivePath else {
        throw UploadError.exportedArchivePathMissing
    }
    try ActionsEnvironment.altool.validate(exportedArchivePath: exportedArchivePath)
}

#endif
