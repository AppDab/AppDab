import Bagbutik
import Foundation
import Logging
import XcbeautifyLib
#if os(macOS)
import XCTestHTMLReportCore
#endif

public protocol BagbutikServiceProtocol {
    func request<T: Decodable>(_ request: Request<T, ErrorResponse>) async throws -> T
    func requestAllPages<T: Decodable & PagedResponse>(_ request: Request<T, ErrorResponse>) async throws -> (responses: [T], data: [T.Data])
    func requestNextPage<T: Decodable & PagedResponse>(for response: T) async throws -> T?
    func requestAllPages<T: Decodable & PagedResponse>(for response: T) async throws -> (responses: [T], data: [T.Data])
}

extension BagbutikService: BagbutikServiceProtocol {}

/// The environment for actions. Through the `ActionsEnvironment` actions has access to shared tools and values.
public enum ActionsEnvironment {
    /// The logger, which through all logs should be sent
    public static var logger = Logger(label: "AppDabActions")

    // MARK: - Service

    internal static var _service: BagbutikServiceProtocol?
    /// The service for interacting with the App Store Connect API
    public static var service: BagbutikServiceProtocol {
        guard let service = _service
        else {
            fatalError("Service not configured. Call \(String(describing: ActionsEnvironment.configureService(jwt:)))")
        }
        return service
    }

    /**
     Configuring the service for interacting with the App Store Connect API

     See the documentation for JWT, for how to obtain the correct keys.

     - Parameters:
        - jwt: The JWT used to authorize API requests.
     */
    public static func configureService(jwt: JWT) {
        _service = BagbutikService(jwt: jwt)
    }

    // MARK: - Shared values

    /// Values shared between actions. Actions can add values to this, which other actions can use.
    public static var values = Values()

    // MARK: - Internal

    internal static var fileManager: FileManagerProtocol = FileManager.default
    internal static var urlSession: AppDabURLSessionProtocol = URLSession.shared
    #if os(macOS)
    internal static var infoPlist: InfoPlistProtocol = InfoPlist()
    internal static var keychain: KeychainProtocol = Keychain()
    internal static var shell: ShellProtocol = Shell()
    internal static var terminal: TerminalProtocol = Terminal()
    internal static var xcodebuild: XcodebuildProtocol = Xcodebuild()
    #endif

    internal static var getCurrentDate: () -> Date = { Date() }
    internal static var parseXcodebuildOutput: (String) -> String? = Parser(additionalLines: { nil }).parse(line:)
    internal static var writeStringFile: (_ contents: String, _ path: String) throws -> Void = { contents, path in
        try contents.write(toFile: path, atomically: true, encoding: .utf8)
    }

    #if os(macOS)
    internal static var generateTestResultHtmlReport: (_ xcresultPath: String) -> String = { xcresultPath in
        Summary(resultPaths: [xcresultPath], renderingMode: .inline).generatedHtmlReport()
    }
    #endif
}
