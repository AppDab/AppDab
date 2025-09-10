@testable import AppDabActions
import XCTest

final class AltoolTests: ActionsTestCase {
    let exportedMacArchivePath = "./Awesome.pkg"
    let exportediOSArchivePath = "./Awesome.ipa"
    let appAppleId = "12345678"

    func testValidate_pkg() throws {
        let temporaryPath = ActionsEnvironment.fileManager.temporaryDirectory.path
        let apiKey = ActionsEnvironment.apiKey
        var expectedCommand = "xcrun altool --validate-app -f '\(exportedMacArchivePath)' --type osx --apiKey '\(apiKey.keyId)' -API_PRIVATE_KEYS_DIR '\(temporaryPath)'"
        if let issuerId = apiKey.issuerId {
            expectedCommand += " --apiIssuer '\(issuerId)'"
        }
        mockShell.mockOutputsByCommand = [expectedCommand: ""]
        try Altool().validate(exportedArchivePath: exportedMacArchivePath)
        XCTAssertEqual(mockFileManager.filesCreated, [
            "\(temporaryPath)/AuthKey_\(ActionsEnvironment.apiKey.keyId).p8"
        ])
        XCTAssertEqual(mockShell.runs, [
            .init(command: expectedCommand, path: ".")
        ])
        XCTAssertEqual(mockLogHandler.logs, [
            .init(level: .debug, message: "🔐 Copying private key to temporary folder '\(temporaryPath)'..."),
            .init(level: .debug, message: "👍 Private key saved"),
            .init(level: .info, message: "🚀 Validating exported archive..."),
            .init(level: .info, message: "🎉 Archive validated"),
            .init(level: .debug, message: "🔐 Deleting private key from temporary folder..."),
            .init(level: .debug, message: "👍 Private key deleted from temporary folder")
        ])
    }

    func testValidate_ipa() throws {
        let temporaryPath = ActionsEnvironment.fileManager.temporaryDirectory.path
        let apiKey = ActionsEnvironment.apiKey
        var expectedCommand = "xcrun altool --validate-app -f '\(exportediOSArchivePath)' --type ios --apiKey '\(apiKey.keyId)' -API_PRIVATE_KEYS_DIR '\(temporaryPath)'"
        if let issuerId = apiKey.issuerId {
            expectedCommand += " --apiIssuer '\(issuerId)'"
        }
        mockShell.mockOutputsByCommand = [expectedCommand: ""]
        try Altool().validate(exportedArchivePath: exportediOSArchivePath)
        XCTAssertEqual(mockShell.runs, [
            .init(command: expectedCommand, path: ".")
        ])
    }

    func testValidate_FailCreatingPrivateKeyFile() throws {
        mockFileManager.failWhenCreatingFiles = true
        XCTAssertThrowsError(try Altool().validate(exportedArchivePath: exportedMacArchivePath)) { error in
            XCTAssertEqual(error as! UploadError, .couldNotSavePrivateKeyFile)
        }
    }

    func testValidate_FailRunningCommand() throws {
        mockShell.failsWhenRunning = true
        XCTAssertThrowsError(try Altool().validate(exportedArchivePath: exportedMacArchivePath)) { error in
            XCTAssertTrue(type(of: error) == ShellError.self)
        }
    }

    func testUpload_pkg() throws {
        let uuid = UUID().uuidString
        let temporaryFolderUrl = ActionsEnvironment.fileManager.temporaryDirectory
        let unpackedFolderUrl = temporaryFolderUrl.appendingPathComponent(uuid)
        let apiKey = ActionsEnvironment.apiKey
        let expectedUnpackCommand = "pkgutil --expand \(exportedMacArchivePath) \(unpackedFolderUrl.path)"
        var expectedUploadCommand = "xcrun altool --upload-package '\(exportedMacArchivePath)' --apple-id '\(appAppleId)' --type osx --bundle-short-version-string '1.0' --bundle-version '4' --bundle-id 'app.AppDab.AppDab' --apiKey '\(apiKey.keyId)' -API_PRIVATE_KEYS_DIR '\(temporaryFolderUrl.path)'"
        if let issuerId = apiKey.issuerId {
            expectedUploadCommand += " --apiIssuer '\(issuerId)'"
        }
        mockShell.mockOutputsByCommand[expectedUnpackCommand] = ""
        mockShell.mockOutputsByCommand[expectedUploadCommand] = ""
        var altool = Altool()
        altool.uuidCreator = { uuid }
        altool.textFileLoader = { fileUrl in
            XCTAssertEqual(fileUrl, unpackedFolderUrl.appendingPathComponent("Distribution"))
            return """
            <?xml version="1.0" encoding="utf-8"?>
            <installer-gui-script minSpecVersion="2">
                <pkg-ref id="app.AppDab.AppDab">
                    <bundle-version>
                        <bundle CFBundleShortVersionString="1.0" CFBundleVersion="4" id="app.AppDab.AppDab" path="AppDab.app"/>
                    </bundle-version>
                </pkg-ref>
            </installer-gui-script>
            """
        }
        try altool.upload(exportedArchivePath: exportedMacArchivePath, appAppleId: appAppleId)
        XCTAssertEqual(mockFileManager.filesCreated, [
            temporaryFolderUrl.appendingPathComponent("AuthKey_\(ActionsEnvironment.apiKey.keyId).p8").path
        ])
        XCTAssertEqual(mockShell.runs, [
            .init(command: expectedUnpackCommand, path: "."),
            .init(command: expectedUploadCommand, path: ".")
        ])
        XCTAssertEqual(mockLogHandler.logs, [
            .init(level: .debug, message: "📦 Unpacking package to temporary folder '\(unpackedFolderUrl.path)'..."),
            .init(level: .info, message: "👍 Read info from package. Bundle ID 'app.AppDab.AppDab', version string '1.0' and bundle version '4'"),
            .init(level: .debug, message: "🔐 Copying private key to temporary folder '\(temporaryFolderUrl.path)'..."),
            .init(level: .debug, message: "👍 Private key saved"),
            .init(level: .info, message: "🚀 Uploading exported archive..."),
            .init(level: .info, message: "🎉 Archive uploaded"),
            .init(level: .debug, message: "🔐 Deleting private key from temporary folder..."),
            .init(level: .debug, message: "👍 Private key deleted from temporary folder")
        ])
    }

    func testUpload_InvalidPkgData() throws {
        let uuid = UUID().uuidString
        let temporaryFolderUrl = ActionsEnvironment.fileManager.temporaryDirectory
        let unpackedFolderUrl = temporaryFolderUrl.appendingPathComponent(uuid)
        let expectedUnpackCommand = "pkgutil --expand \(exportedMacArchivePath) \(unpackedFolderUrl.path)"
        mockShell.mockOutputsByCommand[expectedUnpackCommand] = ""
        var altool = Altool()
        altool.uuidCreator = { uuid }
        altool.textFileLoader = { _ in "" }
        XCTAssertThrowsError(try altool.upload(exportedArchivePath: exportedMacArchivePath, appAppleId: appAppleId)) { error in
            XCTAssertEqual(error as! UploadError, .couldNotReadMacPackageInfo)
        }
        XCTAssertEqual(mockShell.runs, [
            .init(command: expectedUnpackCommand, path: ".")
        ])
        XCTAssertEqual(mockLogHandler.logs, [
            .init(level: .debug, message: "📦 Unpacking package to temporary folder '\(unpackedFolderUrl.path)'..."),
        ])
    }
    
    func testUpload_ipa() throws {
        let uuid = UUID().uuidString
        let temporaryFolderUrl = ActionsEnvironment.fileManager.temporaryDirectory
        let unpackedFolderUrl = temporaryFolderUrl.appendingPathComponent(uuid)
        let apiKey = ActionsEnvironment.apiKey
        let expectedUnpackCommand = "unzip \(exportediOSArchivePath) -d \(unpackedFolderUrl.path)"
        var expectedUploadCommand = "xcrun altool --upload-package '\(exportediOSArchivePath)' --apple-id '\(appAppleId)' --type ios --bundle-short-version-string '1.0' --bundle-version '4' --bundle-id 'app.AppDab.AppDab' --apiKey '\(apiKey.keyId)' -API_PRIVATE_KEYS_DIR '\(temporaryFolderUrl.path)'"
        if let issuerId = apiKey.issuerId {
            expectedUploadCommand += " --apiIssuer '\(issuerId)'"
        }
        mockShell.mockOutputsByCommand[expectedUnpackCommand] = ""
        mockShell.mockOutputsByCommand[expectedUploadCommand] = ""
        mockFileManager.contentsOfDirectoryByPath[unpackedFolderUrl.appendingPathComponent("Payload").path] = ["AppDab.app"]
        var altool = Altool()
        altool.uuidCreator = { uuid }
        altool.binaryFileLoader = { fileUrl, _ in
            XCTAssertEqual(fileUrl, unpackedFolderUrl.appendingPathComponent("Payload/AppDab.app/Info.plist"))
            let binaryPlistUrl = Bundle.module.url(forResource: "Binary-Info", withExtension: "plist")!
            return try! Data(contentsOf: binaryPlistUrl)
        }
        try altool.upload(exportedArchivePath: exportediOSArchivePath, appAppleId: appAppleId)
        XCTAssertEqual(mockFileManager.filesCreated, [
            temporaryFolderUrl.appendingPathComponent("AuthKey_\(ActionsEnvironment.apiKey.keyId).p8").path
        ])
        XCTAssertEqual(mockShell.runs, [
            .init(command: expectedUnpackCommand, path: "."),
            .init(command: expectedUploadCommand, path: ".")
        ])
        XCTAssertEqual(mockLogHandler.logs, [
            .init(level: .debug, message: "📦 Unpacking package to temporary folder '\(unpackedFolderUrl.path)'..."),
            .init(level: .info, message: "👍 Read info from package. Bundle ID 'app.AppDab.AppDab', version string '1.0' and bundle version '4'"),
            .init(level: .debug, message: "🔐 Copying private key to temporary folder '\(temporaryFolderUrl.path)'..."),
            .init(level: .debug, message: "👍 Private key saved"),
            .init(level: .info, message: "🚀 Uploading exported archive..."),
            .init(level: .info, message: "🎉 Archive uploaded"),
            .init(level: .debug, message: "🔐 Deleting private key from temporary folder..."),
            .init(level: .debug, message: "👍 Private key deleted from temporary folder")
        ])
    }
    
    func testUpload_InvalidIpaData() throws {
        let uuid = UUID().uuidString
        let temporaryFolderUrl = ActionsEnvironment.fileManager.temporaryDirectory
        let unpackedFolderUrl = temporaryFolderUrl.appendingPathComponent(uuid)
        let expectedUnpackCommand = "unzip \(exportediOSArchivePath) -d \(unpackedFolderUrl.path)"
        mockShell.mockOutputsByCommand[expectedUnpackCommand] = ""
        mockFileManager.contentsOfDirectoryByPath[unpackedFolderUrl.appendingPathComponent("Payload").path] = ["AppDab.app"]
        var altool = Altool()
        altool.uuidCreator = { uuid }
        altool.binaryFileLoader = { _, _ in Data() }
        XCTAssertThrowsError(try altool.upload(exportedArchivePath: exportediOSArchivePath, appAppleId: appAppleId)) { error in
            XCTAssertEqual(error as! UploadError, .couldNotReadiOSPackageInfo)
        }
        XCTAssertEqual(mockShell.runs, [
            .init(command: expectedUnpackCommand, path: ".")
        ])
        XCTAssertEqual(mockLogHandler.logs, [
            .init(level: .debug, message: "📦 Unpacking package to temporary folder '\(unpackedFolderUrl.path)'..."),
        ])
    }
}

