@testable import AppDabActions
import XCTest

final class InfoPlistTests: ActionsTestCase {
    override func setUp() {
        super.setUp()
        skipTearDownCheck(for: .infoPlist)
    }
    
    func testFindInfoPlist() {
        mockXcodebuild.xcodeprojByPath["."] = "Awesome.xcodeproj"
        mockFileManager.contentsOfDirectoryByPath["./Awesome"] = ["Info.plist"]
        let infoPlist = InfoPlist()
        XCTAssertEqual(try infoPlist.findInfoPlist(), "./Awesome/Info.plist")
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "🔍 Looking up Info.plist file..."),
            Log(level: .trace, message: "Found project folder 'Awesome.xcodeproj'"),
            Log(level: .trace, message: "Looking up Info.plist file in 'Awesome'"),
            Log(level: .info, message: "👍 Found Info.plist file at path: ./Awesome/Info.plist")
        ])
    }

    func testFindInfoPlist_NotFound() {
        mockXcodebuild.xcodeprojByPath["."] = "Awesome.xcodeproj"
        mockFileManager.contentsOfDirectoryByPath["./Awesome"] = []
        let infoPlist = InfoPlist()
        XCTAssertThrowsError(try infoPlist.findInfoPlist()) { error in
            XCTAssertEqual(error as! InfoPlistError, .infoPlistNotFound)
        }
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "🔍 Looking up Info.plist file..."),
            Log(level: .trace, message: "Found project folder 'Awesome.xcodeproj'"),
            Log(level: .trace, message: "Looking up Info.plist file in 'Awesome'")
        ])
    }

    func testLoadInfoPlist() {
        let dataLoaderExpectation = expectation(description: "Data loader expectation")
        let path = "./Awesome/Info.plist"
        let plist = NSMutableDictionary(dictionary: [kCFBundleVersionKey as String: "42"])
        let infoPlist = InfoPlist(dataLoader: { url, _ -> Data in
            XCTAssertEqual(url, URL(fileURLWithPath: path))
            dataLoaderExpectation.fulfill()
            return try! PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0)
        })
        XCTAssertEqual(try infoPlist.loadInfoPlist(at: path), plist)
        XCTAssertEqual(mockLogHandler.logs, [Log(level: .trace, message: "Loading Info.plist file at path: \(path)")])
        wait(for: [dataLoaderExpectation], timeout: 5)
    }

    func testSaveInfoPlist() {
        let dataSaverExpectation = expectation(description: "Data saver expectation")
        let path = "./Awesome/Info.plist"
        let plist = NSDictionary(dictionary: [kCFBundleVersionKey as String: "42"])
        let infoPlist = InfoPlist(dataSaver: { data, savePath in
            XCTAssertEqual(data, try! PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0))
            XCTAssertEqual(savePath, path)
            dataSaverExpectation.fulfill()
        })
        XCTAssertNoThrow(try infoPlist.saveInfoPlist(plist, at: path))
        XCTAssertEqual(mockLogHandler.logs, [Log(level: .trace, message: "Saving data to path: \(path)")])
        wait(for: [dataSaverExpectation], timeout: 5)
    }

    func testInfoPlistErrorDescription() {
        XCTAssertEqual(InfoPlistError.infoPlistNotFound.description, "The Info.plist could not be found")
        XCTAssertEqual(InfoPlistError.wrongTypeForKey(key: "CFBundleVersion", path: "./Awesome/Info.plist").description,
                       "No value found for key 'CFBundleVersion' in Info.plist at path: ./Awesome/Info.plist")
    }
}
