import AppDabActions
import XCTest

final class BuildNumberTests: ActionsTestCase {
    func testBuildNumber_Exact() throws {
        XCTAssertEqual(try ("1337" as AppDabActions.BuildNumber).getValue(), "1337")
    }

    func testBuildNumber_NumberOfCommits() throws {
        mockShell.mockOutputsByCommand = ["git rev-list --count HEAD": "42"]
        XCTAssertEqual(try AppDabActions.BuildNumber.numberOfCommits.getValue(), "42")
        XCTAssertEqual(mockShell.runs, [ShellRun(command: "git rev-list --count HEAD", path: ".")])
    }
}
