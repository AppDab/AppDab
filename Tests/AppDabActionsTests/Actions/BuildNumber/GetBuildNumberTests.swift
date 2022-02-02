import AppDabActions
import XCTest

final class GetBuildNumberTests: ActionsTestCase {
    func testGetBuildNumber() throws {
        mockShell.mockOutputsByCommand = ["xcrun agvtool what-version -terse": "42"]
        XCTAssertEqual(try getBuildNumber(xcodeProjPath: "MyProject/App.xcodeproj"), "42")
        XCTAssertEqual(mockShell.runs, [
            ShellRun(command: "xcrun agvtool what-version -terse", path: "MyProject/App.xcodeproj/.."),
        ])
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "🔍 Reading build number..."),
            Log(level: .trace, message: "⚡️ xcrun agvtool what-version -terse"),
            Log(level: .info, message: "👍 Got build number: 42"),
        ])
    }
}
