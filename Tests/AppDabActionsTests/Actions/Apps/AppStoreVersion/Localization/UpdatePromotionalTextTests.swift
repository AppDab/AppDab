import AppDabActions
import Bagbutik_AppStore
import Bagbutik_Models
import XCTest

final class UpdatePromotionalTextTests: ActionsTestCase {
    func testUpdatePromotionalText() async {
        let updateResponse = AppStoreVersionLocalizationResponse(
            data: .init(id: "some-id", links: .init(self: "")),
            links: .init(self: "")
        )
        mockBagbutikService.setResponse(updateResponse, for: Endpoint(path: "/v1/appStoreVersionLocalizations/some-id", method: .patch))
        let appStoreVersionLocalization = try! await updatePromotionalText(forAppStoreVersionLocalizationId: "some-id",                                   newPromotionalText: "promotional text")
        XCTAssertEqual(appStoreVersionLocalization, updateResponse.data)
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "🚀 Updating promotional text for App Store version localization with id 'some-id'..."),
            Log(level: .info, message: "👍 Promotional text updated")
        ])
    }
}
