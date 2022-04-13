@testable import AppDabActions
import XCTest

final class UploadExportedArchive: ActionsTestCase {
    let exportedArchivePath = "./Awesome.pkg"
    let appAppleId = "12345678"
    
    func testUploadExportedArchive() {
        ActionsEnvironment.values.exportedArchivePath = exportedArchivePath
        try! uploadExportedArchive(appAppleId: appAppleId)
        XCTAssertEqual(mockAltool.uploadedExportedArchivePaths.count, 1)
        XCTAssertEqual(mockAltool.uploadedExportedArchivePaths[0].path, exportedArchivePath)
        XCTAssertEqual(mockAltool.uploadedExportedArchivePaths[0].appAppleId, appAppleId)
    }
    
    func testUploadExportedArchive_SuppliedParams() {
        ActionsEnvironment.values.exportedArchivePath = exportedArchivePath
        let betterExportedArchivePath = "./MoreAwesome.xcarchive"
        try! uploadExportedArchive(exportedArchivePath: betterExportedArchivePath, appAppleId: appAppleId)
        XCTAssertEqual(mockAltool.uploadedExportedArchivePaths.count, 1)
        XCTAssertEqual(mockAltool.uploadedExportedArchivePaths[0].path, betterExportedArchivePath)
        XCTAssertEqual(mockAltool.uploadedExportedArchivePaths[0].appAppleId, appAppleId)
    }

    func testUploadExportedArchive_MissingArchivePath() {
        XCTAssertThrowsError(try uploadExportedArchive(appAppleId: appAppleId)) { error in
            XCTAssertEqual(error as! UploadError, .exportedArchivePathMissing)
        }
    }
}
