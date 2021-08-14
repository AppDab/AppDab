@testable import AppDabActions
import XCTest

final class XcodeProjPathTests: XCTestCase {
    func testGetPathContainingXcodeProjWithPath() {
        let projectPath = "My/Project.xcodeproj"
        XCTAssertEqual(getPathContainingXcodeProj(projectPath), "\(projectPath)/..")
    }

    func testGetPathContainingXcodeProjWithoutPath() {
        XCTAssertEqual(getPathContainingXcodeProj(), ".")
    }
}
