@testable import AppDabActions
import XCTest

final class XcodebuildTests: ActionsTestCase {
    override func setUp() {
        super.setUp()
        skipTearDownCheck(for: .xcodebuild)
    }
    
    func testFindXcodeProject() {
        let xcodeProj = "Awesome.xcodeproj"
        mockFileManager.contentsOfDirectoryByPath["some/path"] = [xcodeProj]
        let xcodebuild = Xcodebuild()
        XCTAssertEqual(try xcodebuild.findXcodeProject(at: "some/path"), xcodeProj)
    }

    func testFindXcodeProject_NotFound() {
        mockFileManager.contentsOfDirectoryByPath["some/path"] = []
        let xcodebuild = Xcodebuild()
        XCTAssertThrowsError(try xcodebuild.findXcodeProject(at: "some/path")) { error in
            XCTAssertEqual(error as! XcodebuildError, .xcodeProjNotFound)
        }
    }

    func testFindSchemeName() {
        let scheme = "Awesome"
        mockFileManager.contentsOfDirectoryByPath["some/path"] = ["\(scheme).xcodeproj"]
        mockShell.mockOutputsByCommand = ["xcodebuild -list": """
        Information about project "Awesome":
            Targets:
                Awesome
                AwesomeTests

            Build Configurations:
                Debug
                Release

            If no build configuration is specified and -scheme is not passed then "Release" is used.

            Schemes:
                Awesome
        """]
        let xcodebuild = Xcodebuild()
        XCTAssertEqual(try xcodebuild.findSchemeName(at: "some/path"), scheme)
        XCTAssertFalse(mockTerminal.selectOptionHasBeenCalled)
    }
    
    func testFindSchemeName_NoMatch() {
        mockFileManager.contentsOfDirectoryByPath["some/path"] = ["Awesome.xcodeproj"]
        mockShell.mockOutputsByCommand = ["xcodebuild -list": """
        Information about project "Awesome":
            Targets:
                Awesome
                AwesomeTests
        
            Build Configurations:
                Debug
                Release
        
            If no build configuration is specified and -scheme is not passed then "Release" is used.
        
            Schemes:
                SoAwesome
                MoreAwesome
        """]
        let xcodebuild = Xcodebuild()
        XCTAssertEqual(try xcodebuild.findSchemeName(at: "some/path"), "SoAwesome")
        XCTAssertTrue(mockTerminal.selectOptionHasBeenCalled)
    }

    func testFindSchemeName_UnknownSchemesListOutput() {
        let scheme = "Awesome"
        mockFileManager.contentsOfDirectoryByPath["some/path"] = ["\(scheme).xcodeproj"]
        let output = "Something not containting the magic word"
        mockShell.mockOutputsByCommand = ["xcodebuild -list": output]
        let xcodebuild = Xcodebuild()
        XCTAssertThrowsError(try xcodebuild.findSchemeName(at: "some/path")) { error in
            XCTAssertEqual(error as! XcodebuildError, .unkownSchemesListOutput(output))
        }
    }
    
    func testXcodebuildErrorDescription() {
        XCTAssertEqual(XcodebuildError.xcodeProjNotFound.description, "Xcode project could not be found")
        XCTAssertEqual(XcodebuildError.unkownSchemesListOutput("some-output").description, "Unexpected format of schemes list. Please report it as an issue on GitHub 🥰\nAttach the following output if possible and the version of Xcode used:\nsome-output")
        XCTAssertEqual(XcodebuildError.archivePathMissing.description, "Archive path is not specified")
        XCTAssertEqual(XcodebuildError.exportedArchiveNotFound.description, "Could not find exported archive")
        XCTAssertEqual(XcodebuildError.testResultNotFound.description, "Could not find test results")
    }
}
