import AppDabActions
import Bagbutik_Core
import XCTest

final class DeleteAppInfoLocalizationTests: ActionsTestCase {
    let deleteResponse = EmptyResponse()

    func testDeleteLocalization_WithId() async {
        mockBagbutikService.setResponse(deleteResponse, for: Endpoint(path: "/v1/appInfoLocalizations/some-id", method: .delete))
        try! await deleteAppInfoLocalization(withId: "some-id")
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "🚀 Deleting localization 'some-id'..."),
            Log(level: .info, message: "👍 Localization deleted"),
        ])
    }
}
