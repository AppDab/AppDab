@testable import AppDabActions
import XCTest

final class ValidateExportedArchive: ActionsTestCase {
    let exportedArchivePath = "./Awesome.pkg"

    func testValidateExportedArchive() {
        ActionsEnvironment.values.exportedArchivePath = exportedArchivePath
        try! validateExportedArchive()
        XCTAssertEqual(mockAltool.validatedExportedArchivePaths, [exportedArchivePath])
    }

    func testValidateExportedArchive_SuppliedParams() {
        ActionsEnvironment.values.exportedArchivePath = exportedArchivePath
        let betterExportedArchivePath = "./MoreAwesome.xcarchive"
        try! validateExportedArchive(exportedArchivePath: betterExportedArchivePath)
        XCTAssertEqual(mockAltool.validatedExportedArchivePaths, [betterExportedArchivePath])
    }

    func testValidateExportedArchive_MissingArchivePath() {
        XCTAssertThrowsError(try validateExportedArchive()) { error in
            XCTAssertEqual(error as! UploadError, .exportedArchivePathMissing)
        }
    }
}
