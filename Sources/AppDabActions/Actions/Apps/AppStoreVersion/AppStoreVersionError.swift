public enum AppStoreVersionError: ActionError {
    case noNewValuesSpecified

    public var description: String {
        switch self {
        case .noNewValuesSpecified:
            return "At least one value needs to be specified."
        }
    }
}
