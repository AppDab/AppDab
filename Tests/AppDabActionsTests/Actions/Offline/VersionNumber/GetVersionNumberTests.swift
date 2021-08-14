import AppDabActions
import XCTest

final class GetVersionNumberTests: ActionsTestCase {
    func testGetVersionNumber() throws {
        mockShell.mockOutputsByCommand = ["xcrun agvtool what-marketing-version -terse1": "1.4.9"]
        XCTAssertEqual(try getVersionNumber(xcodeProjPath: "MyProject/App.xcodeproj"), "1.4.9")
        XCTAssertEqual(mockShell.runs, [
            ShellRun(command: "xcrun agvtool what-marketing-version -terse1", path: "MyProject/App.xcodeproj/.."),
        ])
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "🔍 Reading version number..."),
            Log(level: .trace, message: "⚡️ xcrun agvtool what-marketing-version -terse1"),
            Log(level: .info, message: "👍 Got version number: 1.4.9"),
        ])
    }
}
