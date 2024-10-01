import AppDabActions
import Bagbutik_Models
import Foundation
import XCTest

final class ListBundleIdsTests: ActionsTestCase {
    func testListBundleIds() async {
        let response = BundleIdsResponse(
            data: [.init(id: "bundle-id-1", links: .init(self: ""), attributes: .init(identifier: "com.example.App1", name: "Calculator", platform: .iOS, seedId: "ADS12DSA")),
                   .init(id: "bundle-id-2", links: .init(self: ""), attributes: .init(identifier: "com.example.App2", name: "Browser", platform: .macOS))],
            links: .init(self: "")
        )
        mockBagbutikService.setResponse(response, for: Endpoint(path: "/v1/bundleIds", method: .get))
        let bundleIds = try! await listBundleIds()
        XCTAssertEqual(bundleIds, response.data)
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "🚀 Fetching list of bundle IDs..."),
            Log(level: .info, message: "👍 Bundle IDs fetched"),
            Log(level: .info, message: " ◦ Calculator (ADS12DSA.com.example.App1) for iOS"),
            Log(level: .info, message: " ◦ Browser (com.example.App2) for macOS"),
        ])
    }
}

extension BundleId: @retroactive Equatable {
    public static func == (lhs: BundleId, rhs: BundleId) -> Bool {
        lhs.id == rhs.id
    }
}
