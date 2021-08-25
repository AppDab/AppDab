@testable import AppDabActions
@testable import Bagbutik
import Combine
import Logging
import XCTest

class ActionsTestCase: XCTestCase {
    var mockBagbutikService: MockBagbutikService!
    var mockFileManager: MockFileManager!
    var mockInfoPlist: MockInfoPlist!
    var mockLogHandler: MockLogHandler!
    var mockShell: MockShell!
    var mockTerminal: MockTerminal!
    var mockXcodebuild: MockXcodebuild!

    var mockDate = Date(timeIntervalSince1970: 1623360721)
    var writtenFiles = [WrittenFile]()

    enum EnvironmentDependency: CaseIterable {
        case bagbutikService
        case fileManager
        case infoPlist
        case logHandler
        case shell
        case terminal
        case xcodebuild
    }

    // Should be reset at setUp
    private var dependenciesToSkipTearDownCheck = [EnvironmentDependency]()

    func skipTearDownCheck(for dependency: EnvironmentDependency) {
        dependenciesToSkipTearDownCheck.append(dependency)
    }

    override func setUp() {
        super.setUp()
        ActionsEnvironment.values = Values()
        mockBagbutikService = MockBagbutikService()
        ActionsEnvironment._service = mockBagbutikService
        mockFileManager = MockFileManager()
        ActionsEnvironment.fileManager = mockFileManager
        mockInfoPlist = MockInfoPlist()
        ActionsEnvironment.infoPlist = mockInfoPlist
        mockLogHandler = MockLogHandler()
        ActionsEnvironment.logger = Logger(label: "Mock logger", factory: { _ in self.mockLogHandler })
        mockShell = MockShell()
        ActionsEnvironment.shell = mockShell
        mockTerminal = MockTerminal()
        ActionsEnvironment.terminal = mockTerminal
        mockXcodebuild = MockXcodebuild()
        ActionsEnvironment.xcodebuild = mockXcodebuild

        ActionsEnvironment.getCurrentDate = { self.mockDate }
        ActionsEnvironment.parseXcodebuildOutput = { line, _ in "Parsed: \(line)" }
        ActionsEnvironment.writeStringFile = { contents, path in self.writtenFiles.append(WrittenFile(contents: contents, path: path)) }
        writtenFiles.removeAll()
        ActionsEnvironment.generateTestResultHtmlReport = { path in "Generated HTML report for path: \(path)" }
    }

    override func tearDown() {
        super.tearDown()
        let dependenciesToCheck = EnvironmentDependency.allCases.filter { !dependenciesToSkipTearDownCheck.contains($0) }
        dependenciesToCheck.forEach { dependency in
            switch dependency {
            case .bagbutikService:
                XCTAssertTrue(mockBagbutikService.allEndpointsCalled)
            case .fileManager:
                XCTAssertTrue(mockFileManager.allContentsOfDirectoryCalled)
            case .infoPlist:
                XCTAssertTrue(mockInfoPlist.findInfoPlistCalledIfSpecified)
                XCTAssertTrue(mockInfoPlist.loadInfoPlistCalledIfSpecified)
            case .shell:
                XCTAssertTrue(mockShell.allCommandsCalled)
            case .xcodebuild:
                XCTAssertTrue(mockXcodebuild.allFindXcodeProjectCalled)
                XCTAssertTrue(mockXcodebuild.allFindSchemeNameCalled)
            default:
                break
            }
        }
    }
}

struct WrittenFile: Equatable {
    let contents: String
    let path: String
}

struct Endpoint: Hashable {
    let path: String
    let method: HTTPMethod
}

class MockBagbutikService: BagbutikServiceProtocol {
    private(set) var responseDataByEndpoint = [Endpoint: Data]()
    private(set) var errorResponseDataByEndpoint = [Endpoint: Data]()
    private(set) var requestBodyJsons = [String]()
    private var endpointsCalled = 0
    fileprivate var allEndpointsCalled: Bool { endpointsCalled == responseDataByEndpoint.count + errorResponseDataByEndpoint.count }

    func setResponse<T>(_ response: T, for endpoint: Endpoint) where T: Encodable {
        responseDataByEndpoint[endpoint] = try! JSONEncoder().encode(response)
    }

    func setErrorResponse<T>(_ errorResponse: T, for endpoint: Endpoint) where T: Encodable {
        errorResponseDataByEndpoint[endpoint] = try! JSONEncoder().encode(errorResponse)
    }

    func request<T>(_ request: Request<T, ErrorResponse>) -> AnyPublisher<T, Error> where T: Decodable {
        switch decodeResponseData(for: request) {
        case .success(let response):
            return CurrentValueSubject<T, Error>(response).eraseToAnyPublisher()
        case .failure(let error):
            return Fail(error: error).eraseToAnyPublisher()
        }
    }

    func request<T>(_ request: Request<T, ErrorResponse>, completionHandler: @escaping (Result<T, Error>) -> Void) where T: Decodable {
        switch decodeResponseData(for: request) {
        case .success(let response):
            completionHandler(.success(response))
        case .failure(let error):
            completionHandler(.failure(error))
        }
    }

    func request<T>(_ request: Request<T, ErrorResponse>) async throws -> T where T: Decodable {
        return try decodeResponseData(for: request).get()
    }

    private func decodeResponseData<T>(for request: Request<T, ErrorResponse>) -> Result<T, Error> where T: Decodable {
        if let jsonData = request.requestBody?.jsonData,
           let json = try? JSONSerialization.jsonObject(with: jsonData, options: []),
           let prettyJsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
           let requestBodyJson = String(data: prettyJsonData, encoding: .utf8)
        {
            requestBodyJsons.append(requestBodyJson)
        }
        endpointsCalled += 1
        let endpoint = Endpoint(path: request.path, method: request.method)
        if let responseData = responseDataByEndpoint[endpoint] {
            return .success(try! JSONDecoder().decode(T.self, from: responseData))
        } else if let errorResponseData = errorResponseDataByEndpoint[endpoint] {
            return .failure(try! JSONDecoder().decode(ErrorResponse.self, from: errorResponseData))
        } else {
            XCTFail("Missing response data and error data for endpoint: \(endpoint.method) \(endpoint.path)")
            fatalError()
        }
    }
}

class MockFileManager: FileManagerProtocol {
    var contentsOfDirectoryByPath = [String: [String]]()
    private var contentsOfDirectoryCalled = 0
    fileprivate var allContentsOfDirectoryCalled: Bool { contentsOfDirectoryCalled == contentsOfDirectoryByPath.count }

    func contentsOfDirectory(atPath path: String) throws -> [String] {
        contentsOfDirectoryCalled += 1
        guard let contentsOfDirectory = contentsOfDirectoryByPath[path] else { throw MockError.missingContentsOfDirectoryByPath }
        return contentsOfDirectory
    }
}

class MockInfoPlist: InfoPlistProtocol {
    var infoPlistPath: String?
    var loadedInfoPlist: NSMutableDictionary?
    var savedInfoPlist: NSDictionary?
    private var findInfoPlistCalled = false
    fileprivate var findInfoPlistCalledIfSpecified: Bool { infoPlistPath != nil ? findInfoPlistCalled : true }
    private var loadInfoPlistCalled = false
    fileprivate var loadInfoPlistCalledIfSpecified: Bool { loadedInfoPlist != nil ? loadInfoPlistCalled : true }

    func findInfoPlist() throws -> String {
        findInfoPlistCalled = true
        guard let infoPlistPath = infoPlistPath else { throw MockError.missingInfoPlistPath }
        return infoPlistPath
    }

    func loadInfoPlist(at path: String) throws -> NSMutableDictionary {
        loadInfoPlistCalled = true
        guard let loadedInfoPlist = loadedInfoPlist else { throw MockError.missingLoadedInfoPlist }
        return loadedInfoPlist
    }

    func saveInfoPlist(_ infoPlist: NSDictionary, at path: String) throws {
        savedInfoPlist = infoPlist
    }
}

class MockLogHandler: LogHandler {
    var logLevel: Logger.Level = .trace
    var metadata: Logger.Metadata = [:]
    var logs: [Log] = []

    subscript(metadataKey key: String) -> Logger.Metadata.Value? {
        get { return metadata[key] }
        set(newValue) { metadata[key] = newValue }
    }

    public func log(level: Logger.Level, message: Logger.Message, metadata: Logger.Metadata?, source: String, file: String, function: String, line: UInt) {
        logs.append(Log(level: level, message: message.description))
    }
}

struct Log: Equatable {
    let level: Logger.Level
    let message: String
}

class MockShell: ShellProtocol {
    var runs: [ShellRun] = []
    var mockOutputsByCommand = [String: String]()
    private var commandsCalled = 0
    fileprivate var allCommandsCalled: Bool { commandsCalled == mockOutputsByCommand.count }

    func run(_ command: String, at path: String, outputCallback: ((String) -> Void)?) throws -> String {
        commandsCalled += 1
        runs.append(ShellRun(command: command, path: path))
        guard let output = mockOutputsByCommand[command] else {
            XCTFail("Output not mocked for command: \(command)")
            return ""
        }
        output.split(separator: "\n")
            .map(String.init)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .forEach(outputCallback ?? { _ in })
        return output
    }
}

struct ShellRun: Equatable {
    let command: String
    let path: String
}

class MockTerminal: TerminalProtocol {
    var selectOptionHasBeenCalled = false

    func selectOption(text: String, items: [String], allowTextSelection: Bool) throws -> (index: Int, item: String) {
        selectOptionHasBeenCalled = true
        return (index: 0, item: items[0])
    }

    func getInput(secret: Bool) -> String {
        return ""
    }

    func getBoolInput(question: String) -> Bool {
        return true
    }
}

class MockXcodebuild: XcodebuildProtocol {
    var xcodeprojByPath = [String: String]()
    var schemeByPath = [String: String]()
    private var findXcodeProjectCalled = 0
    fileprivate var allFindXcodeProjectCalled: Bool { findXcodeProjectCalled == xcodeprojByPath.count }
    private var findSchemeNameCalled = 0
    fileprivate var allFindSchemeNameCalled: Bool { findSchemeNameCalled == schemeByPath.count }

    func findXcodeProject(at path: String) throws -> String {
        findXcodeProjectCalled += 1
        guard let xcodeproj = xcodeprojByPath[path] else { throw MockError.missingXcodeprojByPath }
        return xcodeproj
    }

    func findSchemeName(at path: String) throws -> String {
        findSchemeNameCalled += 1
        guard let scheme = schemeByPath[path] else { throw MockError.missingSchemeByPath }
        return scheme
    }
}

enum MockError: Error {
    case missingResponseData
    case missingContentsOfDirectoryByPath
    case missingInfoPlistPath
    case missingLoadedInfoPlist
    case missingXcodeprojByPath
    case missingSchemeByPath
}
