import AppDabActions
import Bagbutik
import Foundation
import XCTest

final class RenameBundleIdTests: ActionsTestCase {
    func testRenameBundleId_WithIdentifier() {
        let fetchResponse = BundleIdsResponse(
            data: [.init(id: "some-id", links: .init(self: ""),
                         attributes: .init(identifier: "com.example.Awesome", name: "Awesome", platform: .universal, seedId: "F65JDS54"),
                         relationships: .init(app: nil, bundleIdCapabilities: nil, profiles: nil))],
            links: .init(self: ""))
        let updateResponse = BundleIdResponse(
            data: .init(id: "some-id", links: .init(self: ""),
                        attributes: .init(identifier: "com.example.Awesome", name: "MoreAwesome", platform: .universal, seedId: "F65JDS54"),
                        relationships: .init(app: nil, bundleIdCapabilities: nil, profiles: nil)),
            links: .init(self: ""))
        mockBagbutikService.setResponse(fetchResponse, for: Endpoint(path: "/v1/bundleIds", method: .get))
        mockBagbutikService.setResponse(updateResponse, for: Endpoint(path: "/v1/bundleIds/some-id", method: .patch))
        try! renameBundleId(withIdentifier: "com.example.Awesome", newName: "MoreAwesome")
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "🚀 Fetching bundle ID by identifier 'com.example.Awesome'..."),
            Log(level: .info, message: "👍 Found bundle ID 'com.example.Awesome' (some-id)"),
            Log(level: .info, message: "🚀 Renaming bundle ID 'some-id' to 'MoreAwesome'..."),
            Log(level: .info, message: "👍 Bundle ID renamed"),
        ])
    }

    func testRenameBundleId_WithIdentifier_NotFound() {
        let fetchResponse = BundleIdsResponse(data: [], links: .init(self: ""))
        mockBagbutikService.setResponse(fetchResponse, for: Endpoint(path: "/v1/bundleIds", method: .get))
        XCTAssertThrowsError(try renameBundleId(withIdentifier: "com.example.Awesome", newName: "MoreAwesome")) { error in
            XCTAssertEqual(error as! BundleIdError, .bundleIdWithIdentifierNotFound("com.example.Awesome"))
        }
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "🚀 Fetching bundle ID by identifier 'com.example.Awesome'..."),
        ])
    }
    
    func testRenameBundleId_WithName() {
        let fetchResponse = BundleIdsResponse(
            data: [.init(id: "some-id", links: .init(self: ""),
                         attributes: .init(identifier: "com.example.Awesome", name: "Awesome", platform: .universal, seedId: "F65JDS54"),
                         relationships: .init(app: nil, bundleIdCapabilities: nil, profiles: nil))],
            links: .init(self: ""))
        let updateResponse = BundleIdResponse(
            data: .init(id: "some-id", links: .init(self: ""),
                        attributes: .init(identifier: "com.example.Awesome", name: "MoreAwesome", platform: .universal, seedId: "F65JDS54"),
                        relationships: .init(app: nil, bundleIdCapabilities: nil, profiles: nil)),
            links: .init(self: ""))
        mockBagbutikService.setResponse(fetchResponse, for: Endpoint(path: "/v1/bundleIds", method: .get))
        mockBagbutikService.setResponse(updateResponse, for: Endpoint(path: "/v1/bundleIds/some-id", method: .patch))
        try! renameBundleId(named: "Awesome", newName: "MoreAwesome")
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "🚀 Fetching bundle ID by name 'Awesome'..."),
            Log(level: .info, message: "👍 Found bundle ID named 'Awesome' (some-id)"),
            Log(level: .info, message: "🚀 Renaming bundle ID 'some-id' to 'MoreAwesome'..."),
            Log(level: .info, message: "👍 Bundle ID renamed"),
        ])
    }
    
    func testRenameBundleId_WithName_NotFound() {
        let fetchResponse = BundleIdsResponse(data: [], links: .init(self: ""))
        mockBagbutikService.setResponse(fetchResponse, for: Endpoint(path: "/v1/bundleIds", method: .get))
        XCTAssertThrowsError(try renameBundleId(named: "Awesome", newName: "MoreAwesome")) { error in
            XCTAssertEqual(error as! BundleIdError, .bundleIdWithNameNotFound("Awesome"))
        }
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "🚀 Fetching bundle ID by name 'Awesome'..."),
        ])
    }
}
