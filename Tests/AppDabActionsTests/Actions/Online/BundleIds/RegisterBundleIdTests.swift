import AppDabActions
import Bagbutik
import Foundation
import XCTest

final class RegisterBundleIdTests: ActionsTestCase {
    func testRegisterBundleId_WithSeedId() async {
        let response = BundleIdResponse(
            data: .init(id: "some-id", links: .init(self: ""),
                        attributes: .init(identifier: "com.example.Awesome", name: "Awesome", platform: .universal, seedId: "F65JDS54"),
                        relationships: .init(app: nil, bundleIdCapabilities: nil, profiles: nil)),
            included: nil, links: .init(self: ""))
        mockBagbutikService.setResponse(response, for: Endpoint(path: "/v1/bundleIds", method: .post))
        let bundleId = try! await registerBundleId(identifier: "com.example.Awesome", name: "Awesome", seedId: "F65JDS54")
        XCTAssertEqual(bundleId, response.data)
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "🚀 Registering a new bundle ID 'F65JDS54.com.example.Awesome' called 'Awesome'"),
            Log(level: .info, message: "👍 Bundle ID registered"),
        ])
    }

    func testRegisterBundleId_WithoutSeedId() async {
        let response = BundleIdResponse(
            data: .init(id: "some-id", links: .init(self: ""),
                        attributes: .init(identifier: "com.example.Awesome", name: "Awesome", platform: .universal),
                        relationships: .init(app: nil, bundleIdCapabilities: nil, profiles: nil)),
            included: nil, links: .init(self: ""))
        mockBagbutikService.setResponse(response, for: Endpoint(path: "/v1/bundleIds", method: .post))
        let bundleId = try! await registerBundleId(identifier: "com.example.Awesome", name: "Awesome")
        XCTAssertEqual(bundleId, response.data)
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "🚀 Registering a new bundle ID 'com.example.Awesome' called 'Awesome'"),
            Log(level: .info, message: "👍 Bundle ID registered"),
        ])
    }
    
    func testRegisterBundleId_WithEmptySeedId() async {
        let response = BundleIdResponse(
            data: .init(id: "some-id", links: .init(self: ""),
                        attributes: .init(identifier: "com.example.Awesome", name: "Awesome", platform: .universal),
                        relationships: .init(app: nil, bundleIdCapabilities: nil, profiles: nil)),
            included: nil, links: .init(self: ""))
        mockBagbutikService.setResponse(response, for: Endpoint(path: "/v1/bundleIds", method: .post))
        let bundleId = try! await registerBundleId(identifier: "com.example.Awesome", name: "Awesome", seedId: "")
        XCTAssertEqual(bundleId, response.data)
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "🚀 Registering a new bundle ID 'com.example.Awesome' called 'Awesome'"),
            Log(level: .info, message: "👍 Bundle ID registered"),
        ])
    }
}
