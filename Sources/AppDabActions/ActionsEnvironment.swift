import Bagbutik_Core
import Foundation
import Logging
import XcbeautifyLib
#if os(macOS)
import XCTestHTMLReportCore
#endif

public protocol BagbutikServiceProtocol {
    func request<T: Decodable>(_ request: Request<T, ErrorResponse>) async throws -> T
    @discardableResult func request(_ request: Request<EmptyResponse, ErrorResponse>) async throws -> EmptyResponse
    func requestAllPages<T: Decodable & PagedResponse>(_ request: Request<T, ErrorResponse>) async throws -> (responses: [T], data: [T.Data])
    func requestNextPage<T: Decodable & PagedResponse>(for response: T) async throws -> T?
    func requestAllPages<T: Decodable & PagedResponse>(for response: T) async throws -> (responses: [T], data: [T.Data])
}

extension BagbutikService: BagbutikServiceProtocol {}

/// The environment for actions. Through the `ActionsEnvironment` actions has access to shared tools and values.
public enum ActionsEnvironment {
    /// The logger, which through all logs should be sent
    public static var logger = Logger(label: "AppDabActions")

    // MARK: - Settings

    public static var settings = Settings()

    // MARK: - Shared values

    /// Values shared between actions. Actions can add values to this, which other actions can use.
    public static var values = Values()

    // MARK: - API Key

    private static var _apiKey: APIKey?
    /**
     The API key for interacting with Apples services (App Store Connect API and altool)

     - Note: Setting this will reset the ``service``.
     */
    public static var apiKey: APIKey {
        get {
            if let _apiKey = _apiKey {
                return _apiKey
            }
            switch settings.apiKeyResolution {
            case .fromKeychain(let keyId):
                return try! getAPIKey(withId: keyId, logLevel: .debug)
            case .fromEnvironmentVariables:
                let envVars = ProcessInfo.processInfo.environment
                guard let keyId = envVars["APPDAB_KEY_ID"],
                      let issuerId = envVars["APPDAB_ISSUER_ID"],
                      let privateKeyPath = envVars["APPDAB_PRIVATE_KEY_PATH"] else {
                    fatalError("The required environment variables for setting up API Key was not found.")
                }
                guard let privateKey = try? String(contentsOfFile: privateKeyPath) else {
                    fatalError("The private key could not be read from the specified path: \(privateKeyPath)")
                }
                return try! APIKey(name: "Unknown", keyId: keyId, issuerId: issuerId, privateKey: privateKey)
            }
        }
        set {
            _apiKey = newValue
            _service = nil
        }
    }

    // MARK: - Service

    internal static var _service: BagbutikServiceProtocol?
    /// The service for interacting with the App Store Connect API
    public static var service: BagbutikServiceProtocol {
        if let _service = _service {
            return _service
        }
        let service = BagbutikService(jwt: apiKey.jwt, fetchData: fetchData)
        _service = service
        return service
    }
    
    public static var keychain: KeychainProtocol = Keychain()
    
    public static var fetchData: FetchData = URLSession.shared.data(for:delegate:)
    public static var uploadData: UploadData = URLSession.shared.upload(for:from:delegate:)
    
    public typealias UploadData = (_ request: URLRequest, _ bodyData: Data, _ delegate: URLSessionTaskDelegate?) async throws -> (Data, URLResponse)

    // MARK: - Internal

    internal static var fileManager: FileManagerProtocol = FileManager.default
    internal static var locale: Locale = .current
    internal static var timeZone: TimeZone = .current
    #if os(macOS)
    internal static var altool: AltoolProtocol = Altool()
    internal static var infoPlist: InfoPlistProtocol = InfoPlist()
    internal static var shell: ShellProtocol = Shell()
    internal static var terminal: TerminalProtocol = Terminal()
    internal static var xcodebuild: XcodebuildProtocol = Xcodebuild()
    #endif

    internal static var getCurrentDate: () -> Date = { Date() }
    internal static var parseXcodebuildOutput: (String) -> String? = XCBeautifier(colored: true, renderer: .terminal, preserveUnbeautifiedLines: false, additionalLines: { nil }).format(line:)
    internal static var writeStringFile: (_ contents: String, _ path: String) throws -> Void = { contents, path in
        try contents.write(toFile: path, atomically: true, encoding: .utf8)
    }

    #if os(macOS)
    internal static var generateTestResultHtmlReport: (_ xcresultPath: String) -> String = { xcresultPath in
        Summary(resultPaths: [xcresultPath], renderingMode: .inline, downsizeImagesEnabled: false, downsizeScaleFactor: 1).generatedHtmlReport()
    }
    #endif
}
