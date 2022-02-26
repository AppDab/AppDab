/// Error happening when manipulating App Store versions.
public enum AppStoreVersionError: ActionError {
    /// No new values specified.
    case noNewValuesSpecified

    public var description: String {
        switch self {
        case .noNewValuesSpecified:
            return "At least one value needs to be specified."
        }
    }
}
