import Bagbutik
import Foundation
import Logging
import XcbeautifyLib
#if os(macOS)
import XCTestHTMLReportCore
#endif

public enum ActionsEnvironment {
    // MARK: - Logger

    public static var logger = Logger(label: "AppDabActions")

    // MARK: - Service

    internal static var _service: BagbutikServiceProtocol?
    public static var service: BagbutikServiceProtocol {
        guard let service = _service
        else {
            fatalError("Service not configured. Call \(String(describing: ActionsEnvironment.configureService(authConfig:)))")
        }
        return service
    }

    public static func configureService(authConfig: AuthConfig) throws {
        _service = try BagbutikService(keyId: authConfig.keyId, issuerId: authConfig.issuerId, privateKey: authConfig.privateKey)
    }

    // MARK: - Shared values

    public static var values = Values()

    // MARK: - Internal

    internal static var fileManager: FileManagerProtocol = FileManager.default
    #if os(macOS)
    internal static var infoPlist: InfoPlistProtocol = InfoPlist()
    internal static var keychain: KeychainProtocol = Keychain()
    internal static var shell: ShellProtocol = Shell()
    internal static var terminal: TerminalProtocol = Terminal()
    internal static var xcodebuild: XcodebuildProtocol = Xcodebuild()
    #endif

    internal static var getCurrentDate: () -> Date = { Date() }
    internal static var parseXcodebuildOutput: (String, Bool) -> String? = Parser().parse(line:colored:)
    internal static var writeStringFile: (_ contents: String, _ path: String) throws -> Void = { contents, path in
        try contents.write(toFile: path, atomically: true, encoding: .utf8)
    }

    #if os(macOS)
    internal static var generateTestResultHtmlReport: (_ xcresultPath: String) -> String = { xcresultPath in
        Summary(resultPaths: [xcresultPath], renderingMode: .inline).generatedHtmlReport()
    }
    #endif
}

public struct AuthConfig {
    public let keyId: String
    public let issuerId: String
    public let privateKey: String

    public init(keyId: String, issuerId: String, privateKey: String) {
        self.keyId = keyId
        self.issuerId = issuerId
        self.privateKey = privateKey
    }
}
