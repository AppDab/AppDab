import AppDabActions
import Bagbutik_Models
import Foundation
import XCTest

final class UpdateAppInfoLocalizationTests: ActionsTestCase {
    func testUpdateAppInfoLocalization() async {
        let fetchResponse = AppInfosResponse(
            data: [.init(id: "some-locked-id", links: .init(self: ""), attributes: .init(appStoreState: .readyForSale)),
                   .init(id: "some-id", links: .init(self: ""), attributes: .init(appStoreState: .prepareForSubmission), relationships: .init(appInfoLocalizations: .init(data: [.init(id: "localization-id")])))],
            included: [.appInfoLocalization(.init(id: "localization-id", links: .init(self: "")))],
            links: .init(self: "")
        )
        let updateResponse = AppInfoLocalizationResponse(
            data: .init(id: "some-id", links: .init(self: "")),
            links: .init(self: "")
        )
        mockBagbutikService.setResponse(fetchResponse, for: Endpoint(path: "/v1/apps/123456789/appInfos", method: .get))
        mockBagbutikService.setResponse(updateResponse, for: Endpoint(path: "/v1/appInfoLocalizations/localization-id", method: .patch))
        let appInfoLocalization = try! await updateAppInfoLocalization(forLocale: "en-US", forAppId: "123456789", newName: "NewCalc", newSubtitle: "Calculator for all your platforms!", newPrivacyPolicyUrl: "https://example.com/privacy-policy.html")
        let logValues = ["new name 'NewCalc'",
                         "new subtitle 'Calculator for all your platforms!'",
                         "new privacy policy URL 'https://example.com/privacy-policy.html'"]
        XCTAssertEqual(appInfoLocalization, updateResponse.data)
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "🚀 Fetching app info localization by locale 'en-US' for app id '123456789'..."),
            Log(level: .info, message: "👍 Found app info localization for locale 'en-US' (localization-id)"),
            Log(level: .info, message: "🚀 Updating localization with id 'localization-id' with \(ListFormatter.localizedString(byJoining: logValues))..."),
            Log(level: .info, message: "👍 Localization updated"),
        ])
    }

    func testUpdateAppInfoLocalization_NoValues() async {
        await XCTAssertAsyncThrowsError(try await updateAppInfoLocalization(withId: "some-id")) { error in
            XCTAssertEqual(error as! AppInfoLocalizationError, .noNewValuesSpecified)
        }
    }

    func testUpdateAppInfoLocalization_ForLocale_NotFound() async {
        let fetchResponse = AppInfosResponse(
            data: [.init(id: "some-locked-id", links: .init(self: ""), attributes: .init(appStoreState: .readyForSale)),
                   .init(id: "some-id", links: .init(self: ""), attributes: .init(appStoreState: .prepareForSubmission), relationships: .init(ageRatingDeclaration: .init(data: .init(id: "ageRatingDeclaration-id"))))],
            included: [.ageRatingDeclaration(.init(id: "ageRatingDeclaration-id", links: .init(self: ""))), .appInfoLocalization(.init(id: "localization-id", links: .init(self: "")))],
            links: .init(self: "")
        )
        mockBagbutikService.setResponse(fetchResponse, for: Endpoint(path: "/v1/apps/123456789/appInfos", method: .get))
        await XCTAssertAsyncThrowsError(try await updateAppInfoLocalization(forLocale: "en-US", forAppId: "123456789", newName: "NewCalc")) { error in
            XCTAssertEqual(error as! AppInfoLocalizationError, .appInfoLocalizationForLocaleNotFound)
        }
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "🚀 Fetching app info localization by locale 'en-US' for app id '123456789'..."),
        ])
    }
}

extension AppInfoLocalization: Equatable {
    public static func == (lhs: AppInfoLocalization, rhs: AppInfoLocalization) -> Bool {
        lhs.id == rhs.id
    }
}
