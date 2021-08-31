import AppDabActions
import Bagbutik
import Foundation
import XCTest

final class InviteUserTests: ActionsTestCase {
    func testInviteUser() async {
        let response = UserInvitationResponse(
            data: .init(id: "some-id", links: .init(self: "")),
            links: .init(self: "")
        )
        mockBagbutikService.setResponse(response, for: Endpoint(path: "/v1/userInvitations", method: .post))
        let userInvitation = try! await inviteUser(email: "sjobs@apple.com", firstName: "Steve", lastName: "Jobs", roles: [.admin], allAppsVisible: true, provisioningAllowed: true)
        XCTAssertEqual(userInvitation, response.data)
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "🚀 Inviting user 'Steve Jobs' (sjobs@apple.com)..."),
            Log(level: .info, message: "👍 User invited"),
        ])
        XCTAssertEqual(mockBagbutikService.requestBodyJsons[0], """
        {
          "data" : {
            "type" : "userInvitations",
            "attributes" : {
              "email" : "sjobs@apple.com",
              "firstName" : "Steve",
              "lastName" : "Jobs",
              "roles" : [
                "ADMIN"
              ],
              "provisioningAllowed" : true,
              "allAppsVisible" : true
            }
          }
        }
        """)
    }

    func testInviteUser_VisibleApps() async {
        let response = UserInvitationResponse(
            data: .init(id: "some-id", links: .init(self: "")),
            links: .init(self: "")
        )
        mockBagbutikService.setResponse(response, for: Endpoint(path: "/v1/userInvitations", method: .post))
        let userInvitation = try! await inviteUser(email: "forstall@apple.com", firstName: "Scott", lastName: "Forstall", roles: [.readOnly], visibleAppIds: ["some-app-id"])
        XCTAssertEqual(userInvitation, response.data)
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "🚀 Inviting user 'Scott Forstall' (forstall@apple.com)..."),
            Log(level: .info, message: "👍 User invited"),
        ])
        XCTAssertEqual(mockBagbutikService.requestBodyJsons[0], """
        {
          "data" : {
            "type" : "userInvitations",
            "attributes" : {
              "email" : "forstall@apple.com",
              "firstName" : "Scott",
              "lastName" : "Forstall",
              "roles" : [
                "READ_ONLY"
              ],
              "provisioningAllowed" : false,
              "allAppsVisible" : false
            },
            "relationships" : {
              "visibleApps" : {
                "data" : [
                  {
                    "id" : "some-app-id",
                    "type" : "apps"
                  }
                ]
              }
            }
          }
        }
        """)
    }
}
