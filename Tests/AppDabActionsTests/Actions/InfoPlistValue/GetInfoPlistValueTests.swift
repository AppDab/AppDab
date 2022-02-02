import AppDabActions
import XCTest

final class GetInfoPlistValueTests: ActionsTestCase {
    func testGetInfoPlistValue() {
        mockInfoPlist.infoPlistPath = "./Awesome/Info.plist"
        mockInfoPlist.loadedInfoPlist = NSMutableDictionary(dictionary: ["CFBundleVersion": "42"])
        XCTAssertEqual(try getInfoPlistValue(forKey: "CFBundleVersion"), "42")
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "🔍 Reading Info.plist value for key 'CFBundleVersion'..."),
            Log(level: .info, message: "👍 Got Info.plist value: 42"),
        ])
    }

    func testGetInfoPlistValue_WrongType() {
        mockInfoPlist.infoPlistPath = "./Awesome/Info.plist"
        mockInfoPlist.loadedInfoPlist = NSMutableDictionary(dictionary: ["CFBundleVersion": "42"])
        do {
            let _: Int = try getInfoPlistValue(forKey: "CFBundleVersion")
        } catch {
            XCTAssertEqual(error as! InfoPlistError, .wrongTypeForKey(key: "CFBundleVersion", path: "./Awesome/Info.plist"))
        }
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "🔍 Reading Info.plist value for key 'CFBundleVersion'..."),
        ])
    }
}
