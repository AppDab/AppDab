public enum BundleIdError: ActionError, Equatable {
    case bundleIdWithIdentifierNotFound(String)
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
