import AppDabActions
import XCTest

final class IncrementBuildNumberTests: ActionsTestCase {
    func testIncrementBuildNumber() throws {
        mockShell.mockOutputsByCommand = ["xcrun agvtool next-version": """
        Setting version of project App to:
            43.
        """]
        try incrementBuildNumber()
        XCTAssertEqual(mockShell.runs, [
            ShellRun(command: "xcrun agvtool next-version", path: "."),
        ])
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "✍️ Incrementing build number..."),
            Log(level: .trace, message: "⚡️ xcrun agvtool next-version"),
            Log(level: .info, message: """
            📔 Output from agvtool:
            Setting version of project App to:
                43.
            """),
        ])
    }
    
    func testIncrementBuildNumber_IncludingInfoPlists() throws {
        mockShell.mockOutputsByCommand = ["xcrun agvtool next-version -all": """
        Setting version of project App to:
            43.

        Also setting CFBundleVersion key (assuming it exists)

        Updating CFBundleVersion in Info.plist(s)...

        Updated CFBundleVersion in "MyProject/App.xcodeproj/../App/App-Info.plist" to 43
        Updated CFBundleVersion in "MyProject/App.xcodeproj/../AppTests/Info.plist" to 43
        Updated CFBundleVersion in "MyProject/App.xcodeproj/../AppUITests/Info.plist" to 43
        """]
        try incrementBuildNumber(xcodeProjPath: "MyProject/App.xcodeproj", includingInfoPlists: true)
        XCTAssertEqual(mockShell.runs, [
            ShellRun(command: "xcrun agvtool next-version -all", path: "MyProject/App.xcodeproj/.."),
        ])
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "✍️ Incrementing build number..."),
            Log(level: .trace, message: "⚡️ xcrun agvtool next-version -all"),
            Log(level: .info, message: """
            📔 Output from agvtool:
            Setting version of project App to:
                43.

            Also setting CFBundleVersion key (assuming it exists)

            Updating CFBundleVersion in Info.plist(s)...

            Updated CFBundleVersion in "MyProject/App.xcodeproj/../App/App-Info.plist" to 43
            Updated CFBundleVersion in "MyProject/App.xcodeproj/../AppTests/Info.plist" to 43
            Updated CFBundleVersion in "MyProject/App.xcodeproj/../AppUITests/Info.plist" to 43
            """),
        ])
    }
}
