import AppDabActions
import Bagbutik_Models
import Foundation
import XCTest

final class ListUserInvitationsTests: ActionsTestCase {
    func testListUserInvitations() async {
        let response = UserInvitationsResponse(
            data: [.init(id: "invitation-1", links: .init(self: ""), attributes: .init(email: "sjobs@apple.com", firstName: "Steve", lastName: "Jobs")),
                   .init(id: "invitation-2", links: .init(self: ""), attributes: .init(email: "forstall@apple.com", firstName: "Scott", lastName: "Forstall"))],
            links: .init(self: "")
        )
        mockBagbutikService.setResponse(response, for: Endpoint(path: "/v1/userInvitations", method: .get))
        let userInvitations = try! await listUserInvitations()
        XCTAssertEqual(userInvitations, response.data)
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "🚀 Fetching list of user invitations..."),
            Log(level: .info, message: "👍 User invitations fetched"),
            Log(level: .info, message: " ◦ Steve Jobs (sjobs@apple.com)"),
            Log(level: .info, message: " ◦ Scott Forstall (forstall@apple.com)"),
        ])
    }
}

extension UserInvitation: @retroactive Equatable {
    public static func == (lhs: UserInvitation, rhs: UserInvitation) -> Bool {
        lhs.id == rhs.id
    }
}
