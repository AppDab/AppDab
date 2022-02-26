/// Error happening when manipulating profiles.
public enum ProfileError: ActionError, Equatable {
    /// The device with name not found.
    case profileWithNameNotFound(String)

    public var description: String {
        switch self {
        case .profileWithNameNotFound(let name):
            return "Profile named '\(name)' not found"
        }
    }
}
