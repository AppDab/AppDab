import AppDabActions
import Bagbutik
import Foundation
import XCTest

final class ListUserTests: ActionsTestCase {
    func testListUsers() async {
        let response = UsersResponse(
            data: [.init(id: "sjobs", links: .init(self: ""), attributes: .init(firstName: "Steve", lastName: "Jobs", username: "sjobs@apple.com")),
                   .init(id: "forstall", links: .init(self: ""), attributes: .init(firstName: "Scott", lastName: "Forstall", username: "forstall@apple.com"))],
            links: .init(self: "")
        )
        mockBagbutikService.setResponse(response, for: Endpoint(path: "/v1/users", method: .get))
        let users = try! await listUsers()
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "🚀 Fetching list of users..."),
            Log(level: .info, message: "👍 Users fetched"),
            Log(level: .info, message: " ◦ Steve Jobs (sjobs@apple.com)"),
            Log(level: .info, message: " ◦ Scott Forstall (forstall@apple.com)"),
        ])
        XCTAssertEqual(users, response.data)
    }
}

extension User: Equatable {
    public static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }
}
