import Bagbutik
import Foundation
import Logging
import XcbeautifyLib
import XCTestHTMLReportCore

public enum ActionsEnvironment {
    // MARK: - Logger

    public static var logger = Logger(label: "AppDabActions")

    // MARK: - Service

    internal static var _service: PatchedBagbutikServiceProtocol?
    public static var service: PatchedBagbutikServiceProtocol {
        guard let service = _service
        else {
            fatalError("Service not configured. Call \(String(describing: ActionsEnvironment.configureService(authConfig:)))")
        }
        return service
    }

    public static func configureService(authConfig: AuthConfig) throws {
        _service = try BagbutikService(keyId: authConfig.keyId, issuerId: authConfig.issuerId, privateKeyPath: authConfig.privateKeyPath)
    }

    // MARK: - Shared values

    public static var values = Values()

    // MARK: - Internal

    internal static var fileManager: FileManagerProtocol = FileManager.default
    internal static var infoPlist: InfoPlistProtocol = InfoPlist()
    internal static var shell: ShellProtocol = Shell()
    internal static var terminal: TerminalProtocol = Terminal()
    internal static var xcodebuild: XcodebuildProtocol = Xcodebuild()

    internal static var getCurrentDate: () -> Date = { Date() }
    internal static var parseXcodebuildOutput: (String, Bool) -> String? = Parser().parse(line:colored:)
    internal static var writeStringFile: (_ contents: String, _ path: String) throws -> Void = { contents, path in
        try contents.write(toFile: path, atomically: true, encoding: .utf8)
    }

    internal static var generateTestResultHtmlReport: (_ xcresultPath: String) -> String = { xcresultPath in
        Summary(resultPaths: [xcresultPath], renderingMode: .inline).generatedHtmlReport()
    }
}

public struct AuthConfig {
    public let keyId: String
    public let issuerId: String
    public let privateKeyPath: String

    public init(keyId: String, issuerId: String, privateKeyPath: String) {
        self.keyId = keyId
        self.issuerId = issuerId
        self.privateKeyPath = privateKeyPath
    }
}

public protocol PatchedBagbutikServiceProtocol: BagbutikServiceProtocol {
    func requestSynchronously<T: Decodable>(_ request: Request<T, ErrorResponse>) -> Result<T, Error>
}
