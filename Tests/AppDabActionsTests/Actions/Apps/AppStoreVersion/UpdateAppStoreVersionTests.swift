import AppDabActions
import Bagbutik
import XCTest

final class UpdateAppStoreVersionTests: ActionsTestCase {
    func testUpdateAppStoreVersion() async {
        let updateResponse = AppStoreVersionResponse(
            data: .init(id: "some-id", links: .init(self: "")),
            links: .init(self: "")
        )
        mockBagbutikService.setResponse(updateResponse, for: Endpoint(path: "/v1/appStoreVersions/some-id", method: .patch))
        let app = try! await updateAppStoreVersion(withId: "some-id", newVersion: "1.3.37", newCopyright: "2022")
        XCTAssertEqual(app, updateResponse.data)
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "🚀 Updating App Store version with id 'some-id' with version '1.3.37' and copyright '2022'..."),
            Log(level: .info, message: "👍 App Store version updated")
        ])
    }

    func testUpdateAppStoreVersion_OnlyCopyright() async {
        let updateResponse = AppStoreVersionResponse(
            data: .init(id: "some-id", links: .init(self: "")),
            links: .init(self: "")
        )
        mockBagbutikService.setResponse(updateResponse, for: Endpoint(path: "/v1/appStoreVersions/some-id", method: .patch))
        let app = try! await updateAppStoreVersion(withId: "some-id", newCopyright: "2022")
        XCTAssertEqual(app, updateResponse.data)
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "🚀 Updating App Store version with id 'some-id' with copyright '2022'..."),
            Log(level: .info, message: "👍 App Store version updated")
        ])
    }

    func testUpdateAppStoreVersion_NoValues() async {
        await XCTAssertAsyncThrowsError(try await updateAppStoreVersion(withId: "some-id")) { error in
            XCTAssertEqual(error as! AppStoreVersionError, .noNewValuesSpecified)
        }
    }
}

extension AppStoreVersion: Equatable {
    public static func == (lhs: AppStoreVersion, rhs: AppStoreVersion) -> Bool {
        lhs.id == rhs.id
    }
}
