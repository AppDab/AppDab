import Foundation

public enum APIKeyError: ActionError, Equatable {
    case invalidAPIKeyFormat
    case duplicateAPIKey
    case failedAddingAPIKey(OSStatus)

    public var description: String {
        switch self {
        case .invalidAPIKeyFormat:
            return "The data for an API Key is invalid"
        case .duplicateAPIKey:
            return "The API Key is already in Keychain"
        case .failedAddingAPIKey(let status):
            return "The API Key could not be added to Keychain (OSStatus \(status)"
        }
    }
}
