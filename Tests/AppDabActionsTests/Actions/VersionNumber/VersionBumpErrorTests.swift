import AppDabActions
import XCTest

final class VersionBumpErrorTests: ActionsTestCase {
    func testVersionBumpErrorDescription() {
        XCTAssertEqual(VersionBumpError.versionPartIsNotInt("bob").description, "Part of version is not an integer: bob")
        XCTAssertEqual(VersionBumpError.cantBump(.patch, version: "1.2").description, "Can't bump patch version because the part is missing from the version (1.2)")
    }
}
