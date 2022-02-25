/// Error happening when manipulating bundle ids.
public enum BundleIdError: ActionError, Equatable {
    /// The bundle id with identifier not found.
    case bundleIdWithIdentifierNotFound(String)
    /// THe bundle id with name not found.
    case bundleIdWithNameNotFound(String)
    
    public var description: String {
        switch self {
        case .bundleIdWithIdentifierNotFound(let identifier):
            return "Bundle ID '\(identifier)' not found"
        case .bundleIdWithNameNotFound(let name):
            return "Bundle ID named '\(name)' not found"
        }
    }
}
