import Foundation

/// Error happening when creating API Keys and adding them to Keychain.
public enum APIKeyError: ActionError, Equatable {
    /// The data for an API Key is invalid.
    case invalidAPIKeyFormat
    /// The API Key is already in Keychain.
    case duplicateAPIKey
    ///The API Key could not be added to Keychain. Lookup the status on <https://osstatus.com>
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
