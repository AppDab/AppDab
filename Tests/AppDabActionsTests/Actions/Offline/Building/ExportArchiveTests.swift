@testable import AppDabActions
import XCTest

final class ExportArchiveTests: ActionsTestCase {
    func testExportArchive() {
        ActionsEnvironment.values.xcarchivePath = "./Awesome.xcarchive"
        mockShell.mockOutputsByCommand = [
            "xcodebuild -exportArchive -archivePath './Awesome.xcarchive' -exportPath '.' -exportOptionsPlist 'ExportOptions.plist'": #"""
            Exported Awesome to: /Users/tim/Projects/awesome
            ** EXPORT SUCCEEDED **
            """#,
        ]
        mockFileManager.contentsOfDirectoryByPath["."] = ["Awesome.ipa"]
        try! exportArchive()
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "🎁 Exporting archive..."),
            Log(level: .info, message: "Parsed: Exported Awesome to: /Users/tim/Projects/awesome"),
            Log(level: .info, message: "Parsed: ** EXPORT SUCCEEDED **"),
            Log(level: .info, message: "🎉 Archive exported"),
            Log(level: .trace, message: "The exported archive is here: ./Awesome.ipa"),
        ])
        XCTAssertEqual(ActionsEnvironment.values.ipaPath, "./Awesome.ipa")
    }

    func testExportArchive_SuppliedParams() {
        ActionsEnvironment.values.xcarchivePath = "./Awesome.xcarchive"
        let expectedCommand = "xcodebuild -exportArchive -archivePath './MoreAwesome.xcarchive' -exportPath 'build' -exportOptionsPlist 'OtherExportOptions.plist'"
        mockShell.mockOutputsByCommand = [expectedCommand: ""]
        mockFileManager.contentsOfDirectoryByPath["build"] = ["MoreAwesome.ipa"]
        try! exportArchive(archivePath: "./MoreAwesome.xcarchive", exportPath: "build", exportOptionsPlist: "OtherExportOptions.plist")
        XCTAssertEqual(mockShell.runs, [ShellRun(command: "xcodebuild -exportArchive -archivePath './MoreAwesome.xcarchive' -exportPath 'build' -exportOptionsPlist 'OtherExportOptions.plist'", path: ".")])
    }

    func testExportArchive_MissingArchivePath() {
        XCTAssertThrowsError(try exportArchive()) { error in
            XCTAssertEqual(error as! XcodebuildError, .archivePathMissing)
        }
        XCTAssertEqual(mockLogHandler.logs, [Log(level: .info, message: "🎁 Exporting archive...")])
    }

    func testExportArchive_ExportedArchiveNotFound() {
        ActionsEnvironment.values.xcarchivePath = "./Awesome.xcarchive"
        mockShell.mockOutputsByCommand = [
            "xcodebuild -exportArchive -archivePath './Awesome.xcarchive' -exportPath '.' -exportOptionsPlist 'ExportOptions.plist'": "",
        ]
        mockFileManager.contentsOfDirectoryByPath["."] = []
        XCTAssertThrowsError(try exportArchive()) { error in
            XCTAssertEqual(error as! XcodebuildError, .exportedArchiveNotFound)
        }
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "🎁 Exporting archive..."),
            Log(level: .info, message: "🎉 Archive exported"),
        ])
    }
}
