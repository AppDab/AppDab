import AppDabActions
import XCTest

final class BundleIdErrorTests: XCTestCase {
    func testBundleIdErrorDescription() {
        XCTAssertEqual(BundleIdError.bundleIdWithIdentifierNotFound("some-id").description, "Bundle ID 'some-id' not found")
        XCTAssertEqual(BundleIdError.bundleIdWithNameNotFound("Awesome").description, "Bundle ID named 'Awesome' not found")
    }
}
