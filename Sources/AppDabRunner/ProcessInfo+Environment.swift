import Foundation

public extension ProcessInfo {
    /// Is this process started by Xcode
    var runFromXcode: Bool {
        self.environment["__CFBundleIdentifier"] == "com.apple.dt.Xcode"
    }

    var runOnCI: Bool {
        let knownCiEnvironmentVars = [
            "TF_BUILD", // Azure Pipelines
            "CI", // Bitrise
            "CIRCLECI", // Circle CI
            "CIRRUS_CI", // Cirrus CI
            "GITHUB_ACTIONS", // GitHub Actions
            "GITLAB_CI", // GitLab CI
            "BUILD_ID", // Hudson/Jenkins
            "TEAMCITY_VERSION", // TeamCity
            "TRAVIS" // Travis
        ]
        return self.environment.keys.contains(where: knownCiEnvironmentVars.contains(_:))
    }
}
