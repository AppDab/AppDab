import AppDabActions
import XCTest

final class SetVersionNumberTests: ActionsTestCase {
    func testSetVersionNumber() throws {
        mockShell.mockOutputsByCommand = [
            "xcrun agvtool new-marketing-version 1.5.0": """
            Setting CFBundleShortVersionString of project App to:
                1.5.0.
            
            Updating CFBundleShortVersionString in Info.plist(s)...
            
            Updated CFBundleShortVersionString in "MyProject/App.xcodeproj/../App/App-Info.plist" to 1.5.0
            Updated CFBundleShortVersionString in "MyProject/App.xcodeproj/../AppTests/Info.plist" to 1.5.0
            Updated CFBundleShortVersionString in "MyProject/App.xcodeproj/../AppUITests/Info.plist" to 1.5.0
            """,
        ]
        try setVersionNumber("1.5.0", xcodeProjPath: "MyProject/App.xcodeproj")
        XCTAssertEqual(mockShell.runs, [
            ShellRun(command: "xcrun agvtool new-marketing-version 1.5.0", path: "MyProject/App.xcodeproj/.."),
        ])
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "✍️ Setting version number to '1.5.0'..."),
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
