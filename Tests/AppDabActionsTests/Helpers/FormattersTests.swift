@testable import AppDabActions
import XCTest

final class FormattersTests: ActionsTestCase {
    func testDateTimeFormatter() {
        XCTAssertEqual(Formatters.dateTimeFormatter.string(from: mockDate), "10 June 2021 at 21.32.01")
    }
    
    func testRelativeDateTimeFormatter() {
        let date = Date(timeIntervalSinceNow: -130)
        XCTAssertEqual(Formatters.relativeDateTimeFormatter.string(for: date), "2 minutes ago")
    }
    
    func testDateFolderFormatter() {
        XCTAssertEqual(Formatters.dateFolderFormatter.string(from: mockDate), "2021-06-10")
    }
    
    func testArchiveDateTimeFormatter() {
        XCTAssertEqual(Formatters.archiveDateTimeFormatter.string(from: mockDate), "10-06-2021, 21.32")
    }
}
