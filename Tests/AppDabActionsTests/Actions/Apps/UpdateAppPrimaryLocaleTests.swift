import AppDabActions
import Bagbutik_AppStore
import Bagbutik_Models
import XCTest

final class UpdateAppPrimaryLocaleTests: ActionsTestCase {
    func testUpdateAppPrimaryLocale() async {
        let updateResponse = AppResponse(
            data: .init(id: "some-id", links: .init(self: "")),
            links: .init(self: "")
        )
        mockBagbutikService.setResponse(updateResponse, for: Endpoint(path: "/v1/apps/some-id", method: .patch))
        let app = try! await updateAppPrimaryLocale(forAppId: "some-id", newPrimaryLocale: "da")
        XCTAssertEqual(app, updateResponse.data)
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "🚀 Updating primary locale 'da' for app with id 'some-id'..."),
            Log(level: .info, message: "👍 Primary locale updated")
        ])
    }
}
