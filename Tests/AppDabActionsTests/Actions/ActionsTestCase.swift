@testable import AppDabActions
@testable import Bagbutik
import Combine
import Logging
import XCTest

class ActionsTestCase: XCTestCase {
    var mockBagbutikService: MockBagbutikService!
    var mockFileManager: MockFileManager!
    var mockInfoPlist: MockInfoPlist!
    var mockKeychain: MockKeychain!
    var mockLogHandler: MockLogHandler!
    var mockShell: MockShell!
    var mockTerminal: MockTerminal!
    var mockURLSession: MockURLSession!
    var mockXcodebuild: MockXcodebuild!

    var mockDate = Date(timeIntervalSince1970: 1_623_360_721)
    var writtenFiles = [WrittenFile]()

    enum EnvironmentDependency: CaseIterable {
        case bagbutikService
        case fileManager
        case infoPlist
        case keychain
        case logHandler
        case shell
        case terminal
        case urlSession
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
        mockKeychain = MockKeychain()
        ActionsEnvironment.keychain = mockKeychain
        mockLogHandler = MockLogHandler()
        ActionsEnvironment.logger = Logger(label: "Mock logger", factory: { _ in self.mockLogHandler })
        mockShell = MockShell()
        ActionsEnvironment.shell = mockShell
        mockTerminal = MockTerminal()
        ActionsEnvironment.terminal = mockTerminal
        mockURLSession = MockURLSession()
        ActionsEnvironment.urlSession = mockURLSession
        mockXcodebuild = MockXcodebuild()
        ActionsEnvironment.xcodebuild = mockXcodebuild

        ActionsEnvironment.getCurrentDate = { self.mockDate }
        ActionsEnvironment.parseXcodebuildOutput = { line in "Parsed: \(line)" }
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
                XCTAssertTrue(mockBagbutikService.allEndpointsCalled, "Not all mocked endpoints were called. If this is expected, add a call to skipTearDownCheck(for: .bagbutikService)")
            case .fileManager:
                XCTAssertTrue(mockFileManager.allContentsOfDirectoryCalled, "Not all mocked directories were listed. If this is expected, add a call to skipTearDownCheck(for: .fileManager)")
            case .infoPlist:
                XCTAssertTrue(mockInfoPlist.findInfoPlistCalledIfSpecified, "Not all mocked lookups for info.plists were called. If this is expected, add a call to skipTearDownCheck(for: .infoPlist)")
                XCTAssertTrue(mockInfoPlist.loadInfoPlistCalledIfSpecified, "Not all mocked loadings of info.plists were called. If this is expected, add a call to skipTearDownCheck(for: .infoPlist)")
            case .shell:
                XCTAssertTrue(mockShell.allCommandsCalled, "Not all mocked calls were called. If this is expected, add a call to skipTearDownCheck(for: .shell)")
            case .xcodebuild:
                XCTAssertTrue(mockXcodebuild.allFindXcodeProjectCalled, "Not all mocked lookups for Xcode projects were called. If this is expected, add a call to skipTearDownCheck(for: .xcodebuild)")
                XCTAssertTrue(mockXcodebuild.allFindSchemeNameCalled, "Not all mocked lookups for scheme names were called. If this is expected, add a call to skipTearDownCheck(for: .xcodebuild)")
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

    func request<T>(_ request: Request<T, ErrorResponse>) async throws -> T where T: Decodable {
        try decodeResponseData(for: request).get()
    }

    func requestAllPages<T>(_ request: Request<T, ErrorResponse>) async throws -> (responses: [T], data: [T.Data]) where T: PagedResponse, T: Decodable {
        let response = try decodeResponseData(for: request).get()
        return (responses: [response], data: response.data)
    }

    func requestNextPage<T>(for response: T) async throws -> T? where T: PagedResponse, T: Decodable {
        response
    }

    func requestAllPages<T>(for response: T) async throws -> (responses: [T], data: [T.Data]) where T: PagedResponse, T: Decodable {
        (responses: [response], data: response.data)
    }

    private func decodeResponseData<T>(for request: Request<T, ErrorResponse>) -> Result<T, Error> where T: Decodable {
        if let jsonData = request.requestBody?.jsonData,
           let json = try? JSONSerialization.jsonObject(with: jsonData, options: []),
           let prettyJsonData = try? JSONSerialization.data(withJSONObject: json, options: [.sortedKeys, .prettyPrinted]),
           let requestBodyJson = String(data: prettyJsonData, encoding: .utf8) {
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

class MockKeychain: KeychainProtocol {
    // MARK: SecItemCopyMatching

    var keychainLookup: (_ query: CFDictionary, _ result: UnsafeMutablePointer<CFTypeRef?>?) -> OSStatus = { _, _ in errSecSuccess }

    // MARK: SecItemAdd

    private(set) var parametersForAdd: [[String: Any]] = []
    var returnStatusForAdd: OSStatus = errSecSuccess

    // MARK: SecItemUpdate

    private(set) var parametersForUpdate: [[String: Any]] = []
    var returnStatusForUpdate: OSStatus = errSecSuccess

    // MARK: SecItemDelete

    private(set) var parametersForDelete: [[String: Any]] = []
    var returnStatusForDelete: OSStatus = errSecSuccess

    // MARK: SecKeyCreateRandomKey

    private(set) var parametersForCreateRandomKey: [[String: Any]] = []
    var createRandomKeyShouldSucceed = true

    // MARK: SecKeyCopyPublicKey

    var publicKeyToReturn: SecKey?
    var copyPublicKeyShouldSucceed = true

    // MARK: SecKeyCopyExternalRepresentation

    var copyPublicKeyDataShouldSucceed = true

    // MARK: Certificates in Keychain

    var serialNumbersForCertificatesInKeychain: [String] = []

    // MARK: Generic passwords in Keychain

    var genericPasswordsInKeychain: [GenericPassword] = []

    lazy var keychain: Keychain = {
        Keychain(secItemCopyMatching: keychainLookup, secItemAdd: { parameters, _ in
            self.parametersForAdd.append(parameters as! [String: Any])
            return self.returnStatusForAdd
        }, secItemUpdate: { parameters, _ in
            self.parametersForUpdate.append(parameters as! [String: Any])
            return self.returnStatusForUpdate
        }, secItemDelete: { parameters in
            self.parametersForDelete.append(parameters as! [String: Any])
            return self.returnStatusForDelete
        }, secKeyCreateRandomKey: { parameters, errorPointer in
            self.parametersForCreateRandomKey.append(parameters as! [String: Any])
            guard self.createRandomKeyShouldSucceed else {
                let error = CFErrorCreate(nil, "SecKeyCreateRandomKey" as CFString, -1, nil)!
                errorPointer?.initialize(to: Unmanaged.passRetained(error))
                return nil
            }
            return SecKeyCreateRandomKey(parameters, errorPointer)
        }, secKeyCopyPublicKey: { privateKey in
            guard self.copyPublicKeyShouldSucceed else {
                return nil
            }
            if let publicKeyToReturn = self.publicKeyToReturn {
                return publicKeyToReturn
            }
            return SecKeyCopyPublicKey(privateKey)
        }, secKeyCopyExternalRepresentation: { publicKey, errorPointer in
            guard self.copyPublicKeyDataShouldSucceed else {
                let error = CFErrorCreate(nil, "SecKeyCopyExternalRepresentation" as CFString, -1, nil)!
                errorPointer?.initialize(to: Unmanaged.passRetained(error))
                return nil
            }
            return SecKeyCopyExternalRepresentation(publicKey, errorPointer)
        })
    }()

    func addCertificate(certificate: SecCertificate, named name: String) throws {
        try keychain.addCertificate(certificate: certificate, named: name)
    }

    func hasCertificates(serialNumbers: [String]) throws -> [String: Bool] {
        serialNumbers.reduce(into: [:]) { result, serialNumber in
            result[serialNumber] = serialNumbersForCertificatesInKeychain.contains(serialNumber)
        }
    }

    func createPrivateKey(labeled label: String) throws -> SecKey {
        try keychain.createPrivateKey(labeled: label)
    }

    func createPublicKey(from privateKey: SecKey) throws -> (key: SecKey, data: Data) {
        return try keychain.createPublicKey(from: privateKey)
    }

    func listGenericPasswords(forService service: String) throws -> [GenericPassword] {
        genericPasswordsInKeychain
    }

    func addGenericPassword(forService service: String, password: GenericPassword) throws {
        try keychain.addGenericPassword(forService: service, password: password)
    }

    func updateGenericPassword(forService service: String, account: String, password: GenericPassword) throws {
        try keychain.updateGenericPassword(forService: service, account: account, password: password)
    }

    func deleteGenericPassword(forService service: String, password: GenericPassword) throws {
        try keychain.deleteGenericPassword(forService: service, password: password)
    }
}

class MockLogHandler: LogHandler {
    var logLevel: Logger.Level = .trace
    var metadata: Logger.Metadata = [:]
    var logs: [Log] = []

    subscript(metadataKey key: String) -> Logger.Metadata.Value? {
        get { metadata[key] }
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
        ""
    }

    func getBoolInput(question: String) -> Bool {
        true
    }
}

class MockURLSession: AppDabURLSessionProtocol {
    var uploadResult: [URL: (data: Data, response: URLResponse, delay: Int)] = [:]

    func upload(for request: URLRequest, from bodyData: Data, delegate: URLSessionTaskDelegate?) async throws -> (Data, URLResponse) {
        guard let url = request.url, let uploadResult = uploadResult[url] else {
            throw MockError.missingResponseData
        }
        if uploadResult.delay > 0 {
            try await Task.sleep(nanoseconds: UInt64(uploadResult.delay * 1_000_000_000))
        }
        return (uploadResult.data, uploadResult.response)
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
