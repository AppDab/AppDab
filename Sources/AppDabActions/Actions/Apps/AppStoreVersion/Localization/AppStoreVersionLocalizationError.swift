/// Error happening when manipulating App Store version localizations.
public enum AppStoreVersionLocalizationError: ActionError {
    /// No new values specified.
    case noNewValuesSpecified

    public var description: String {
        switch self {
        case .noNewValuesSpecified:
            return "At least one value needs to be specified."
        }
    }
}
