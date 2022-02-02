public enum AppInfoLocalizationError: ActionError {
    case noNewValuesSpecified
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
