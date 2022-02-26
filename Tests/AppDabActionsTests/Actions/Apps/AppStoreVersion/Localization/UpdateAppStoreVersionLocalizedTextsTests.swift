import AppDabActions
import Bagbutik
import XCTest

final class UpdateAppStoreVersionLocalizedTextsTests: ActionsTestCase {
    func testUpdateAppStoreVersionLocalizedTexts() async {
        let updateResponse = AppStoreVersionLocalizationResponse(
            data: .init(id: "some-id", links: .init(self: "")),
            links: .init(self: "")
        )
        mockBagbutikService.setResponse(updateResponse, for: Endpoint(path: "/v1/appStoreVersionLocalizations/some-id", method: .patch))
        let appStoreVersionLocalization = try! await updateAppStoreVersionLocalizedTexts(forAppStoreVersionLocalizationId: "some-id",
                                                                                         newDescription: "some description",
                                                                                         newKeywords: "some keywords",
                                                                                         newWhatsNew: "some what's new",
                                                                                         newPromotionalText: "some promotional text",
                                                                                         newMarketingUrl: "some marketing url",
                                                                                         newSupportUrl: "some support url")
        XCTAssertEqual(appStoreVersionLocalization, updateResponse.data)
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "🚀 Updating App Store version localization texts with id 'some-id' with description, keywords, what's new, promotional text, marketing URL, and support URL..."),
            Log(level: .info, message: "👍 App Store version localization texts updated")
        ])
    }

    func testUpdateAppStoreVersionLocalizedTexts_OnlyDescription() async {
        let updateResponse = AppStoreVersionLocalizationResponse(
            data: .init(id: "some-id", links: .init(self: "")),
            links: .init(self: "")
        )
        mockBagbutikService.setResponse(updateResponse, for: Endpoint(path: "/v1/appStoreVersionLocalizations/some-id", method: .patch))
        let appStoreVersionLocalization = try! await updateAppStoreVersionLocalizedTexts(forAppStoreVersionLocalizationId: "some-id",
                                                                                         newDescription: "some description")
        XCTAssertEqual(appStoreVersionLocalization, updateResponse.data)
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "🚀 Updating App Store version localization texts with id 'some-id' with description..."),
            Log(level: .info, message: "👍 App Store version localization texts updated")
        ])
    }

    func testUpdateAppStoreVersionLocalizedTexts_NoValues() async {
        await XCTAssertAsyncThrowsError(try await updateAppStoreVersionLocalizedTexts(forAppStoreVersionLocalizationId: "some-id")) { error in
            XCTAssertEqual(error as! AppStoreVersionLocalizationError, .noNewValuesSpecified)
        }
    }
}

extension AppStoreVersionLocalization: Equatable {
    public static func == (lhs: AppStoreVersionLocalization, rhs: AppStoreVersionLocalization) -> Bool {
        lhs.id == rhs.id
    }
}
