/// Error happening when manipulating app info localizations.
public enum AppInfoLocalizationError: ActionError {
    /// No new values specified.
    case noNewValuesSpecified
    /// App info localization for locale not found.
    case appInfoLocalizationForLocaleNotFound
    
    public var description: String {
        switch self {
        case .noNewValuesSpecified:
            return "At least one value needs to be specified."
        case .appInfoLocalizationForLocaleNotFound:
            return "App info localization for locale not found"
        }
    }
}
