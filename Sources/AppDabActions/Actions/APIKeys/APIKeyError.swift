public enum APIKeyError: ActionError {
    case invalidAPIKeyFormat
    case duplicateAPIKey

    public var description: String {
        switch self {
        case .invalidAPIKeyFormat:
            return "The data for an API Key is invalid"
        case .duplicateAPIKey:
            return "The API Key is already in Keychain"
        }
    }
}
