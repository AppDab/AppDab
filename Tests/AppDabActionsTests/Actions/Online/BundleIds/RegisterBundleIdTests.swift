import AppDabActions
import Bagbutik
import Foundation
import XCTest

final class RegisterBundleIdTests: ActionsTestCase {
    func testRegisterBundleId_WithSeedId() {
        let response = BundleIdResponse(
            data: .init(id: "some-id", links: .init(self: ""),
                        attributes: .init(identifier: "com.example.Awesome", name: "Awesome", platform: .universal, seedId: "F65JDS54"),
                        relationships: .init(app: nil, bundleIdCapabilities: nil, profiles: nil)),
            included: nil, links: .init(self: ""))
        mockBagbutikService.setResponse(response, for: Endpoint(path: "/v1/bundleIds", method: .post))
        try! registerBundleId(identifier: "com.example.Awesome", name: "Awesome", platform: .universal, seedId: "F65JDS54")
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "🚀 Registering a new bundle ID 'F65JDS54.com.example.Awesome' called 'Awesome' for Universal"),
            Log(level: .info, message: "👍 Bundle ID registered"),
        ])
    }

    func testRegisterBundleId_WithoutSeedId() {
        let response = BundleIdResponse(
            data: .init(id: "some-id", links: .init(self: ""),
                        attributes: .init(identifier: "com.example.Awesome", name: "Awesome", platform: .universal),
                        relationships: .init(app: nil, bundleIdCapabilities: nil, profiles: nil)),
            included: nil, links: .init(self: ""))
        mockBagbutikService.setResponse(response, for: Endpoint(path: "/v1/bundleIds", method: .post))
        try! registerBundleId(identifier: "com.example.Awesome", name: "Awesome", platform: .universal)
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "🚀 Registering a new bundle ID 'com.example.Awesome' called 'Awesome' for Universal"),
            Log(level: .info, message: "👍 Bundle ID registered"),
        ])
    }
}
