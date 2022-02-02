import AppDabActions
import XCTest

final class SetInfoPlistValueTests: ActionsTestCase {
    func testSetInfoPlistValue() {
        mockInfoPlist.infoPlistPath = "./Awesome/Info.plist"
        mockInfoPlist.loadedInfoPlist = NSMutableDictionary(dictionary: ["CFBundleVersion": "42"])
        XCTAssertNoThrow(try setInfoPlistValue("1337", forKey: "CFBundleVersion"))
        XCTAssertEqual(mockInfoPlist.savedInfoPlist, ["CFBundleVersion": "1337"])
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "✍️ Setting Info.plist value '1337' for key 'CFBundleVersion'..."),
            Log(level: .info, message: "👍 Info.plist value updated"),
        ])
    }
}
