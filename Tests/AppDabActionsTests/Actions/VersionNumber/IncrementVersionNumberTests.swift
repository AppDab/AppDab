import AppDabActions
import XCTest

final class IncrementVersionNumberTests: ActionsTestCase {
    func testIncrementVersionNumber() throws {
        mockShell.mockOutputsByCommand = [
            "xcrun agvtool what-marketing-version -terse1": "1.4.9",
            "xcrun agvtool new-marketing-version 1.5.0":
                """
                Setting CFBundleShortVersionString of project App to:
                    1.5.0.
                
                Updating CFBundleShortVersionString in Info.plist(s)...
                
                Updated CFBundleShortVersionString in "MyProject/App.xcodeproj/../App/App-Info.plist" to 1.5.0
                Updated CFBundleShortVersionString in "MyProject/App.xcodeproj/../AppTests/Info.plist" to 1.5.0
                Updated CFBundleShortVersionString in "MyProject/App.xcodeproj/../AppUITests/Info.plist" to 1.5.0
                """,
        ]
        try incrementVersionNumber(.minor, xcodeProjPath: "MyProject/App.xcodeproj")
        XCTAssertEqual(mockShell.runs, [
            ShellRun(command: "xcrun agvtool what-marketing-version -terse1", path: "MyProject/App.xcodeproj/.."),
            ShellRun(command: "xcrun agvtool new-marketing-version 1.5.0", path: "MyProject/App.xcodeproj/.."),
        ])
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "🔍 Reading version number..."),
            Log(level: .trace, message: "⚡️ xcrun agvtool what-marketing-version -terse1"),
            Log(level: .info, message: "👍 Got version number: 1.4.9"),
            Log(level: .info, message: "✍️ Incrementing minor version (1.4.9 -> 1.5.0)..."),
            Log(level: .trace, message: "⚡️ xcrun agvtool new-marketing-version 1.5.0"),
            Log(level: .info, message: """
            📔 Output from agvtool:
            Setting CFBundleShortVersionString of project App to:
                1.5.0.
            
            Updating CFBundleShortVersionString in Info.plist(s)...
            
            Updated CFBundleShortVersionString in "MyProject/App.xcodeproj/../App/App-Info.plist" to 1.5.0
            Updated CFBundleShortVersionString in "MyProject/App.xcodeproj/../AppTests/Info.plist" to 1.5.0
            Updated CFBundleShortVersionString in "MyProject/App.xcodeproj/../AppUITests/Info.plist" to 1.5.0
            """),
        ])
    }
}
