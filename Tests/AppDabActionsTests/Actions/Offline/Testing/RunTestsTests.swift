import AppDabActions
import XCTest

final class RunTestsTests: ActionsTestCase {
    func testRunTests() {
        mockXcodebuild.schemeByPath["."] = "Awesome"
        mockShell.mockOutputsByCommand["xcodebuild test -scheme 'Awesome' -destination 'platform=iOS Simulator,name=iPhone 12 Pro'"] = [
            "Test session results, code coverage, and logs:",
            "    /Users/tim/Library/Developer/Xcode/DerivedData/Awesome-cejhwwaclfrpqzdanyrdkpzenviz/Logs/Test/Test-Awesome-2021.07.05_21-00-36-+0200.xcresult",
            " ",
            "** TEST SUCCEEDED ** [13.37 sec]",
        ].joined(separator: "\n")
        try! runTests()
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "🧪 Running tests..."),
            Log(level: .info, message: "Parsed: Test session results, code coverage, and logs:"),
            Log(level: .info, message: "Parsed: /Users/tim/Library/Developer/Xcode/DerivedData/Awesome-cejhwwaclfrpqzdanyrdkpzenviz/Logs/Test/Test-Awesome-2021.07.05_21-00-36-+0200.xcresult"),
            Log(level: .info, message: ""),
            Log(level: .info, message: "Parsed: ** TEST SUCCEEDED ** [13.37 sec]"),
            Log(level: .trace, message: "The test result is here: /Users/tim/Library/Developer/Xcode/DerivedData/Awesome-cejhwwaclfrpqzdanyrdkpzenviz/Logs/Test/Test-Awesome-2021.07.05_21-00-36-+0200.xcresult"),
            Log(level: .info, message: "🎉 Test finished running. The report is here: ./TestResult.html"),
        ])
        XCTAssertEqual(writtenFiles, [
            WrittenFile(contents: "Generated HTML report for path: /Users/tim/Library/Developer/Xcode/DerivedData/Awesome-cejhwwaclfrpqzdanyrdkpzenviz/Logs/Test/Test-Awesome-2021.07.05_21-00-36-+0200.xcresult",
                        path: "./TestResult.html"),
        ])
    }
    
    func testRunTests_SuppliedParams() {
        mockShell.mockOutputsByCommand["xcodebuild test -scheme 'MoreAwesome' -destination 'platform=iOS Simulator,name=iPhone 12 Pro'"] = [
            "Test session results, code coverage, and logs:",
            "    /Users/tim/Library/Developer/Xcode/DerivedData/MoreAwesome-cejhwwaclfrpqzdanyrdkpzenviz/Logs/Test/Test-MoreAwesome-2021.07.05_21-00-36-+0200.xcresult",
            " ",
            "** TEST SUCCEEDED ** [13.37 sec]",
        ].joined(separator: "\n")
        try! runTests(xcodeProjPath: "Awesome.xcodeproj", schemeName: "MoreAwesome")
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "🧪 Running tests..."),
            Log(level: .info, message: "Parsed: Test session results, code coverage, and logs:"),
            Log(level: .info, message: "Parsed: /Users/tim/Library/Developer/Xcode/DerivedData/MoreAwesome-cejhwwaclfrpqzdanyrdkpzenviz/Logs/Test/Test-MoreAwesome-2021.07.05_21-00-36-+0200.xcresult"),
            Log(level: .info, message: ""),
            Log(level: .info, message: "Parsed: ** TEST SUCCEEDED ** [13.37 sec]"),
            Log(level: .trace, message: "The test result is here: /Users/tim/Library/Developer/Xcode/DerivedData/MoreAwesome-cejhwwaclfrpqzdanyrdkpzenviz/Logs/Test/Test-MoreAwesome-2021.07.05_21-00-36-+0200.xcresult"),
            Log(level: .info, message: "🎉 Test finished running. The report is here: Awesome.xcodeproj/../TestResult.html"),
        ])
        XCTAssertEqual(writtenFiles, [
            WrittenFile(contents: "Generated HTML report for path: /Users/tim/Library/Developer/Xcode/DerivedData/MoreAwesome-cejhwwaclfrpqzdanyrdkpzenviz/Logs/Test/Test-MoreAwesome-2021.07.05_21-00-36-+0200.xcresult",
                        path: "Awesome.xcodeproj/../TestResult.html"),
        ])
    }

    func testRunTests_ResultsNotFound() {
        mockXcodebuild.schemeByPath["."] = "Awesome"
        mockShell.mockOutputsByCommand["xcodebuild test -scheme 'Awesome' -destination 'platform=iOS Simulator,name=iPhone 12 Pro'"] = ""
        XCTAssertThrowsError(try runTests()) { error in
            XCTAssertEqual(error as! XcodebuildError, .testResultNotFound)
        }
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "🧪 Running tests..."),
        ])
    }
}
