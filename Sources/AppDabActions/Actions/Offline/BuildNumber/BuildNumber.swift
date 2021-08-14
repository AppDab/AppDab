import Foundation

/// A representation of a future build number. It could either an exact build number or the number of commits on the current Git branch.
public enum BuildNumber: ExpressibleByStringLiteral {
    public typealias StringLiteralType = String

    public init(stringLiteral value: Self.StringLiteralType) {
        self = .exact(value)
    }

    /// The number of commits on the current Git branch
    case numberOfCommits
    /// An exact build number
    case exact(String)

    /**
     Get the value for the future build number. If the build number is based on number of commits, the Git command will be run

     - Returns: The evaluated build number
     */
    public func getValue() throws -> String {
        switch self {
        case .exact(let value):
            return value
        case .numberOfCommits:
            return try ActionsEnvironment.shell.run("git rev-list --count HEAD")
        }
    }
}
