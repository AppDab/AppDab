/// A method for bumping a version. Versions with 3 places (major, minor and patch) are supported.
public enum VersionBump: String, Sendable {
    /// The first number in the version
    case major
    /// The second number in the version
    case minor
    /// The third number in the version
    case patch

    /**
     Bumps the specified version with the method for bumping a version.
     
     - Parameter version: The version to bump
     - Returns: The bumped version
     */
    public func bumpVersion(_ version: String) throws -> String {
        var versionComponents: [Int] = try version.split(separator: ".").map { (part: Substring) -> Int in
            guard let number = Int(part) else {
                throw VersionBumpError.versionPartIsNotInt(String(part))
            }
            return number
        }
        var indexToBump: Int?
        if self == .major, versionComponents.count > 0 {
            indexToBump = 0
        } else if self == .minor, versionComponents.count > 1 {
            indexToBump = 1
        } else if self == .patch, versionComponents.count > 2 {
            indexToBump = 2
        }
        guard let indexToBump = indexToBump else {
            throw VersionBumpError.cantBump(self, version: version)
        }
        var indexBumped = false
        for (index, component) in versionComponents.enumerated() {
            if index == indexToBump {
                versionComponents[index] = component + 1
                indexBumped = true
            } else if indexBumped {
                versionComponents[index] = 0
            }
        }
        return versionComponents.map(String.init).joined(separator: ".")
    }
}
