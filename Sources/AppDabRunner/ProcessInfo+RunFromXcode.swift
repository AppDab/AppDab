import Foundation

public extension ProcessInfo {
    /// Is this process started by Xcode
    var runFromXcode: Bool {
        self.environment["__CFBundleIdentifier"] == "com.apple.dt.Xcode"
    }
}
