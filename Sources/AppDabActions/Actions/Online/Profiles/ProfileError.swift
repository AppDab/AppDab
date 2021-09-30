import Bagbutik

public enum ProfileError: ActionError, Equatable {
    case profileWithNameNotFound(String)
    case profileTypeCantBeCreated(Profile.Attributes.ProfileType)

    public var description: String {
        switch self {
        case .profileWithNameNotFound(let name):
            return "Profile named '\(name)' not found"
        case .profileTypeCantBeCreated(let profileType):
            return "Profiles of type '\(profileType.prettyName)' can't be created"
        }
    }
}
