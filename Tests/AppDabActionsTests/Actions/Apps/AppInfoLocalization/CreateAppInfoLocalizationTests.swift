import AppDabActions
import Bagbutik_AppStore
import Bagbutik_Models
import Foundation
import XCTest

final class CreateAppInfoLocalizationTests: ActionsTestCase {
    func testCreateAppInfoLocalization() async {
        let fetchResponse = AppInfosResponse(
            data: [.init(id: "some-locked-id", links: .init(self: ""), attributes: .init(state: .readyForDistribution)),
                   .init(id: "some-id", links: .init(self: ""), attributes: .init(state: .prepareForSubmission), relationships: .init(appInfoLocalizations: .init(data: [.init(id: "localization-id")])))],
            included: [.appInfoLocalization(.init(id: "localization-id", links: .init(self: "")))],
            links: .init(self: "")
        )
        let createResponse = AppInfoLocalizationResponse(
            data: .init(id: "some-id", links: .init(self: "")),
            links: .init(self: "")
        )
        mockBagbutikService.setResponse(fetchResponse, for: Endpoint(path: "/v1/apps/123456789/appInfos", method: .get))
        mockBagbutikService.setResponse(createResponse, for: Endpoint(path: "/v1/appInfoLocalizations", method: .post))
        let appInfoLocalization = try! await createAppInfoLocalization(forLocale: "en-US", forAppId: "123456789", name: "NewCalc", subtitle: "Calculator for all your platforms!", privacyPolicyUrl: "https://example.com/privacy-policy.html")
        let logValues = ["name 'NewCalc'",
                         "subtitle 'Calculator for all your platforms!'",
                         "privacy policy URL 'https://example.com/privacy-policy.html'"]
        XCTAssertEqual(appInfoLocalization, createResponse.data)
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "🚀 Fetching app info for app id '123456789'..."),
            Log(level: .info, message: "👍 Found app info for app id '123456789' (some-id)"),
            Log(level: .info, message: "🚀 Create localization with \(ListFormatter.localizedString(byJoining: logValues))..."),
            Log(level: .info, message: "👍 Localization created"),
        ])
    }

    func testCreateAppInfoLocalization_NoValues() async {
        await XCTAssertAsyncThrowsError(try await createAppInfoLocalization(forLocale: "da", forAppInfoId: "some-id")) { error in
            XCTAssertEqual(error as! AppInfoLocalizationError, .noNewValuesSpecified)
        }
    }
}
