import AppDabActions
import XCTest

final class SetBuildNumberTests: ActionsTestCase {
    func testSetBuildNumber() throws {
        mockShell.mockOutputsByCommand = ["xcrun agvtool new-version -all 42": """
        Setting version of project App to:
            42.

        Also setting CFBundleVersion key (assuming it exists)

        Updating CFBundleVersion in Info.plist(s)...

        Updated CFBundleVersion in "MyProject/App.xcodeproj/../App/App-Info.plist" to 42
        Updated CFBundleVersion in "MyProject/App.xcodeproj/../AppTests/Info.plist" to 42
        Updated CFBundleVersion in "MyProject/App.xcodeproj/../AppUITests/Info.plist" to 42
        """]
        try setBuildNumber("42", xcodeProjPath: "MyProject/App.xcodeproj")
        XCTAssertEqual(mockShell.runs, [
            ShellRun(command: "xcrun agvtool new-version -all 42", path: "MyProject/App.xcodeproj/.."),
        ])
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "✍️ Setting build number to '42'..."),
            Log(level: .trace, message: "⚡️ xcrun agvtool new-version -all 42"),
            Log(level: .info, message: """
            📔 Output from agvtool:
            Setting version of project App to:
                42.

            Also setting CFBundleVersion key (assuming it exists)

            Updating CFBundleVersion in Info.plist(s)...

            Updated CFBundleVersion in "MyProject/App.xcodeproj/../App/App-Info.plist" to 42
            Updated CFBundleVersion in "MyProject/App.xcodeproj/../AppTests/Info.plist" to 42
            Updated CFBundleVersion in "MyProject/App.xcodeproj/../AppUITests/Info.plist" to 42
            """),
        ])
    }
}
