/// Errors that can occur when bumping a version.
public enum VersionBumpError: ActionError, Equatable {
    /// A part of the version is not an Int
    case versionPartIsNotInt(String)
    /// The part of the version can't be bumped
    case cantBump(VersionBump, version: String)

    public var description: String {
        switch self {
        case .versionPartIsNotInt(let part):
            return "Part of version is not an integer: \(part)"
        case .cantBump(let bump, let version):
            return "Can't bump \(bump) version because the part is missing from the version (\(version))"
        }
    }
}
