import AppDabActions
import Bagbutik_Models
import Foundation
import XCTest

final class ListProfilesTests: ActionsTestCase {
    func testListProfiles() async {
        let expirationDateInFuture = Date.now.addingTimeInterval(10000)
        let expirationDateInFutureString = expirationDateInFuture.formatted(date: .abbreviated, time: .shortened)
        let expirationDateInPastString = mockDate.formatted(date: .abbreviated, time: .shortened)
        let response = ProfilesResponse(
            data: [.init(id: "profile-1", links: .init(self: ""), attributes: .init(expirationDate: expirationDateInFuture, name: "Calculator Distribution", profileState: .active, uuid: "SOME-UUID")),
                   .init(id: "profile-2", links: .init(self: ""), attributes: .init(expirationDate: expirationDateInFuture, name: "YouTube Distribution", profileState: .invalid, uuid: "OTHER-UUID")),
                   .init(id: "profile-3", links: .init(self: ""), attributes: .init(expirationDate: mockDate, name: "Game Center Distribution", profileState: .active, uuid: "ANOTHER-UUID"))],
            links: .init(self: "")
        )
        mockBagbutikService.setResponse(response, for: Endpoint(path: "/v1/profiles", method: .get))
        let profiles = try! await listProfiles()
        XCTAssertEqual(profiles, response.data)
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "🚀 Fetching list of profiles..."),
            Log(level: .info, message: "👍 Profiles fetched"),
            Log(level: .info, message: " ◦ 🟢 Calculator Distribution (SOME-UUID) expires \(expirationDateInFutureString)"),
            Log(level: .info, message: " ◦ 🔴 YouTube Distribution (OTHER-UUID) expires \(expirationDateInFutureString)"),
            Log(level: .info, message: " ◦ 🔴 Game Center Distribution (ANOTHER-UUID) expired \(expirationDateInPastString)"),
            Log(level: .info, message: "⚠️ Expired profiles are only shown in the Developer Portal: https://developer.apple.com/account/resources/profiles/list")
        ])
    }
}

extension Profile: @retroactive Equatable {
    public static func == (lhs: Profile, rhs: Profile) -> Bool {
        lhs.id == rhs.id
    }
}
