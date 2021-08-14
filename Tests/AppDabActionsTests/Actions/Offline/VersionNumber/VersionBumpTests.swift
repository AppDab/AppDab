import AppDabActions
import XCTest

final class VersionBumpTests: ActionsTestCase {
    func testVersionBumpMajor() throws {
        XCTAssertEqual(try VersionBump.major.bumpVersion("1"), "2")
    }
    
    func testVersionBumpMinor() throws {
        XCTAssertEqual(try VersionBump.minor.bumpVersion("1.1"), "1.2")
    }
    
    func testVersionBumpPatch() throws {
        XCTAssertEqual(try VersionBump.patch.bumpVersion("1.1.1"), "1.1.2")
    }
    
    func testVersionBumpPartIsNotInt() throws {
        XCTAssertThrowsError(try VersionBump.major.bumpVersion("1.1.a")) { error in
            XCTAssertEqual(error as! VersionBumpError, .versionPartIsNotInt("a"))
        }
    }

    func testVersionBumpCantBump() throws {
        XCTAssertThrowsError(try VersionBump.patch.bumpVersion("1.1")) { error in
            XCTAssertEqual(error as! VersionBumpError, .cantBump(.patch, version: "1.1"))
        }
    }
}
