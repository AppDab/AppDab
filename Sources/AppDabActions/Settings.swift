/// Settings used in actions.
public struct Settings {
    /// The method to resolve the API Key.
    public let apiKey: APIKeyResolution
    /// The path to a specific Xcode project.
    public let xcodeProjPath: String?
    /// The name of the scheme to build and archive.
    public let schemeName: String?
    /// The path of the folder to contain the exported archive.
    public let exportPath: String
    /// The path to the [export options plist](https://developer.apple.com/library/archive/technotes/tn2339/_index.html#//apple_ref/doc/uid/DTS40014588-CH1-WHAT_KEYS_CAN_I_PASS_TO_THE_EXPORTOPTIONSPLIST_FLAG_).
    public let exportOptionsPlistPath: String
    /// The Apple ID for the app in App Store Connect.
    public let appAppleId: String?
    
    /**
     Instantiate a ``Settings`` struct with settings used in actions.
     
     - Parameter apiKey: The method to resolve the API Key.
     - Parameter xcodeProjPath: The path to a specific Xcode project.
     - Parameter schemeName: The name of the scheme to build and archive.
     - Parameter exportPath: The path of the folder to contain the exported archive.
     - Parameter exportOptionsPlistPath: The path to the [export options plist](https://developer.apple.com/library/archive/technotes/tn2339/_index.html#//apple_ref/doc/uid/DTS40014588-CH1-WHAT_KEYS_CAN_I_PASS_TO_THE_EXPORTOPTIONSPLIST_FLAG_).
     - Parameter appAppleId: The Apple ID for the app in App Store Connect.
     */
    public init(apiKey: APIKeyResolution = .fromEnvironmentVariables,
                xcodeProjPath: String? = nil,
                schemeName: String? = nil,
                exportPath: String = "./output",
                exportOptionsPlistPath: String = "ExportOptions.plist",
                appAppleId: String? = nil) {
        self.apiKey = apiKey
        self.xcodeProjPath = xcodeProjPath
        self.schemeName = schemeName
        self.exportPath = exportPath
        self.exportOptionsPlistPath = exportOptionsPlistPath
        self.appAppleId = appAppleId
    }
}

/// The method to resolve the API Key to use.
public enum APIKeyResolution {
    /// Create the API Key from values passed to the environment.
    case fromEnvironmentVariables
    /// Create the API Key from values in Keychain.
    case fromKeychain(_ keyId: String)
}
