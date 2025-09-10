import AppDabActions
import Bagbutik_Core
import Bagbutik_Models
import Bagbutik_Provisioning
import Foundation
import XCTest

final class DeleteProfileTests: ActionsTestCase {
    func testDeleteProfile_WithId() async {
        let deleteResponse = EmptyResponse()
        mockBagbutikService.setResponse(deleteResponse, for: Endpoint(path: "/v1/profiles/some-id", method: .delete))
        try! await deleteProfile(withId: "some-id")
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "🚀 Deleting profile 'some-id'..."),
            Log(level: .info, message: "👍 Profile deleted"),
        ])
    }

    func testDeleteProfile_WithName() async {
        let fetchResponse = ProfilesResponse(
            data: [.init(id: "some-id", links: .init(self: ""))],
            links: .init(self: ""))
        let deleteResponse = EmptyResponse()
        mockBagbutikService.setResponse(fetchResponse, for: Endpoint(path: "/v1/profiles", method: .get))
        mockBagbutikService.setResponse(deleteResponse, for: Endpoint(path: "/v1/profiles/some-id", method: .delete))
        try! await deleteProfile(named: "Awesome Distribution")
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "🚀 Fetching profile by name 'Awesome Distribution'..."),
            Log(level: .info, message: "👍 Found profile named 'Awesome Distribution' (some-id)"),
            Log(level: .info, message: "🚀 Deleting profile 'some-id'..."),
            Log(level: .info, message: "👍 Profile deleted"),
        ])
    }

    func testDeleteProfile_WithName_NotFound() async {
        let fetchResponse = ProfilesResponse(data: [], links: .init(self: ""))
        mockBagbutikService.setResponse(fetchResponse, for: Endpoint(path: "/v1/profiles", method: .get))
        await XCTAssertAsyncThrowsError(try await deleteProfile(named: "Awesome Distribution")) { error in
            XCTAssertEqual(error as! ProfileError, .profileWithNameNotFound("Awesome Distribution"))
        }
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "🚀 Fetching profile by name 'Awesome Distribution'..."),
        ])
    }
}
