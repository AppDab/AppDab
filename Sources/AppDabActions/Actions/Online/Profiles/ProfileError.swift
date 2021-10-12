import Bagbutik

public enum ProfileError: ActionError, Equatable {
    case profileWithNameNotFound(String)

    public var description: String {
        switch self {
        case .profileWithNameNotFound(let name):
            return "Profile named '\(name)' not found"
        }
    }
}
