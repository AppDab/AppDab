public enum UploadError: ActionError, Equatable {
    case exportedArchivePathMissing
    case couldNotReadiOSPackageInfo
    case couldNotReadMacPackageInfo
    case couldNotSavePrivateKeyFile

    public var description: String {
        switch self {
        case .exportedArchivePathMissing:
            return "Exported archive path is not specified"
        case .couldNotReadiOSPackageInfo:
            return "Could not read info for iOS package"
        case .couldNotReadMacPackageInfo:
            return "Could not read info for macOS package"
        case .couldNotSavePrivateKeyFile:
            return "Could not save private key in temporary folder"
        }
    }
}
