import AppDabActions
import Bagbutik_Models
import Foundation
import XCTest

final class CreateProfileTests: ActionsTestCase {
    func testCrateProfile() async {
        let response = ProfileResponse(
            data: .init(id: "some-id", links: .init(self: "")),
            links: .init(self: "")
        )
        mockBagbutikService.setResponse(response, for: Endpoint(path: "/v1/profiles", method: .post))
        let profile = try! await createProfile(named: "Calculator Development", profileType: .iOSAppDevelopment, bundleIdId: "com.apple.Calculator", certificateIds: ["cert-1"], deviceIds: ["device-1", "device-2"])
        XCTAssertEqual(profile, response.data)
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "🚀 Creating a new profile called 'Calculator Development'..."),
            Log(level: .info, message: "👍 Profile created"),
        ])
        XCTAssertEqual(mockBagbutikService.requestBodyJsons[0], """
        {
          "data" : {
            "attributes" : {
              "name" : "Calculator Development",
              "profileType" : "IOS_APP_DEVELOPMENT"
            },
            "relationships" : {
              "bundleId" : {
                "data" : {
                  "id" : "com.apple.Calculator",
                  "type" : "bundleIds"
                }
              },
              "certificates" : {
                "data" : [
                  {
                    "id" : "cert-1",
                    "type" : "certificates"
                  }
                ]
              },
              "devices" : {
                "data" : [
                  {
                    "id" : "device-1",
                    "type" : "devices"
                  },
                  {
                    "id" : "device-2",
                    "type" : "devices"
                  }
                ]
              }
            },
            "type" : "profiles"
          }
        }
        """)
    }
}
