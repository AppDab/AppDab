import AppDabActions
import Bagbutik
import XCTest

final class ListAppsTests: ActionsTestCase {
    func testListApps() async {
        let response = AppsResponse(
            data: [.init(id: "app-1", links: .init(self: ""), attributes: .init(bundleId: "com.apple.Calculator", name: "Calculator")),
                   .init(id: "app-2", links: .init(self: ""), attributes: .init(bundleId: "com.apple.Safari", name: "Safari"))],
            links: .init(self: "")
        )
        mockBagbutikService.setResponse(response, for: Endpoint(path: "/v1/apps", method: .get))
        let apps = try! await listApps()
        XCTAssertEqual(apps, response.data)
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "🚀 Fetching list of apps..."),
            Log(level: .info, message: "👍 Apps fetched"),
            Log(level: .info, message: " ◦ Calculator (com.apple.Calculator)"),
            Log(level: .info, message: " ◦ Safari (com.apple.Safari)"),
        ])
    }
}

extension App: Equatable {
    public static func == (lhs: App, rhs: App) -> Bool {
        lhs.id == rhs.id
    }
}
