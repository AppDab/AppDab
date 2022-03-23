import AppDabActions
import XCTest

final class BuildAndArchiveTests: ActionsTestCase {
    func testBuildAndArchive() {
        mockXcodebuild.schemeByPath = [".": "Awesome"]
        mockShell.mockOutputsByCommand = [
            "xcodebuild archive -scheme 'Awesome' -archivePath 'Awesome 10-06-2021, 21.32.xcarchive'": #"""
            Command line invocation:
                /Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild archive -scheme 'Awesome' -archivePath 'Awesome 10-06-2021, 21.32.xcarchive'

            Resolve Package Graph
            Fetching from https://github.com/apple/swift-log (cached)
            Cloning local copy of package ‘swift-log’
            Checking out 1.4.2 of package ‘swift-log’

            Resolved source packages:
              swift-log: https://github.com/apple/swift-log @ 1.4.2
            """#,
            "mkdir -p ~/Library/Developer/Xcode/Archives/2021-06-10": "",
            "mv 'Awesome 10-06-2021, 21.32.xcarchive' ~/Library/Developer/Xcode/Archives/2021-06-10": "",
        ]
        try! buildAndArchive()
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "📦 Building and archiving..."),
            Log(level: .info, message: "Parsed: Command line invocation:"),
            Log(level: .info, message: "Parsed: /Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild archive -scheme \'Awesome\' -archivePath \'Awesome 10-06-2021, 21.32.xcarchive\'"),
            Log(level: .info, message: "Parsed: Resolve Package Graph"),
            Log(level: .info, message: "Parsed: Fetching from https://github.com/apple/swift-log (cached)"),
            Log(level: .info, message: "Parsed: Cloning local copy of package ‘swift-log’"),
            Log(level: .info, message: "Parsed: Checking out 1.4.2 of package ‘swift-log’"),
            Log(level: .info, message: "Parsed: Resolved source packages:"),
            Log(level: .info, message: "Parsed: swift-log: https://github.com/apple/swift-log @ 1.4.2"),
            Log(level: .info, message: "🚚 Moving archive to Xcode\'s Archives folder..."),
            Log(level: .info, message: "🎉 Project built and archived. The archive is available in Xcode\'s Organizer"),
            Log(level: .trace, message: "The archive is here: ~/Library/Developer/Xcode/Archives/2021-06-10/Awesome 10-06-2021, 21.32.xcarchive"),
        ])
    }
}
