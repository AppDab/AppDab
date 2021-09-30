import AppDabActions
import Bagbutik
import Foundation
import XCTest

final class DeleteBundleIdTests: ActionsTestCase {
    let fetchResponse = BundleIdsResponse(
        data: [.init(id: "some-id", links: .init(self: ""),
                     attributes: .init(identifier: "com.example.Awesome", name: "Awesome", platform: .universal, seedId: "F65JDS54"),
                     relationships: .init(app: nil, bundleIdCapabilities: nil, profiles: nil))],
        links: .init(self: ""))
    let deleteResponse = EmptyResponse()
    
    func testDeleteBundleId_WithId() async {
        mockBagbutikService.setResponse(deleteResponse, for: Endpoint(path: "/v1/bundleIds/some-id", method: .delete))
        try! await deleteBundleId(withId: "some-id")
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "🚀 Deleting bundle ID 'some-id'..."),
            Log(level: .info, message: "👍 Bundle ID deleted"),
        ])
    }
    
    func testDeleteBundleId_WithIdentifier() async {
        mockBagbutikService.setResponse(fetchResponse, for: Endpoint(path: "/v1/bundleIds", method: .get))
        mockBagbutikService.setResponse(deleteResponse, for: Endpoint(path: "/v1/bundleIds/some-id", method: .delete))
        try! await deleteBundleId(withIdentifier: "com.example.Awesome")
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "🚀 Fetching bundle ID by identifier 'com.example.Awesome'..."),
            Log(level: .info, message: "👍 Found bundle ID 'com.example.Awesome' (some-id)"),
            Log(level: .info, message: "🚀 Deleting bundle ID 'some-id'..."),
            Log(level: .info, message: "👍 Bundle ID deleted"),
        ])
    }

    func testDeleteBundleId_WithIdentifier_NotFound() async {
        let fetchResponse = BundleIdsResponse(data: [], links: .init(self: ""))
        mockBagbutikService.setResponse(fetchResponse, for: Endpoint(path: "/v1/bundleIds", method: .get))
        await XCTAssertAsyncThrowsError(try await deleteBundleId(withIdentifier: "com.example.Awesome")) { error in
            XCTAssertEqual(error as! BundleIdError, .bundleIdWithIdentifierNotFound("com.example.Awesome"))
        }
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "🚀 Fetching bundle ID by identifier 'com.example.Awesome'..."),
        ])
    }

    func testDeleteBundleId_WithName() async {
        mockBagbutikService.setResponse(fetchResponse, for: Endpoint(path: "/v1/bundleIds", method: .get))
        mockBagbutikService.setResponse(deleteResponse, for: Endpoint(path: "/v1/bundleIds/some-id", method: .delete))
        try! await deleteBundleId(named: "Awesome")
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "🚀 Fetching bundle ID by name 'Awesome'..."),
            Log(level: .info, message: "👍 Found bundle ID named 'Awesome' (some-id)"),
            Log(level: .info, message: "🚀 Deleting bundle ID 'some-id'..."),
            Log(level: .info, message: "👍 Bundle ID deleted"),
        ])
    }

    func testDeleteBundleId_WithName_NotFound() async {
        let fetchResponse = BundleIdsResponse(data: [], links: .init(self: ""))
        mockBagbutikService.setResponse(fetchResponse, for: Endpoint(path: "/v1/bundleIds", method: .get))
        await XCTAssertAsyncThrowsError(try await deleteBundleId(named: "Awesome")) { error in
            XCTAssertEqual(error as! BundleIdError, .bundleIdWithNameNotFound("Awesome"))
        }
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "🚀 Fetching bundle ID by name 'Awesome'..."),
        ])
    }
}
