import AppDabActions
import Bagbutik_Models
import XCTest

final class ListDevicesTests: ActionsTestCase {
    func testListDevices() async {
        let response = DevicesResponse(
            data: [.init(id: "device-1", links: .init(self: ""), attributes: .init(deviceClass: .iPhone, name: "iFun", status: .enabled, udid: "iphone-udid")),
                   .init(id: "device-2", links: .init(self: ""), attributes: .init(deviceClass: .mac, name: "AndCheese", status: .disabled, udid: "mac-udid"))],
            links: .init(self: "")
        )
        mockBagbutikService.setResponse(response, for: Endpoint(path: "/v1/devices", method: .get))
        let devices = try! await listDevices()
        XCTAssertEqual(devices, response.data)
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "🚀 Fetching list of devices..."),
            Log(level: .info, message: "👍 Devices fetched"),
            Log(level: .info, message: " ◦ 🟢 iFun (iPhone) - iphone-udid"),
            Log(level: .info, message: " ◦ 🔴 AndCheese (Mac) - mac-udid"),
        ])
    }
}

extension Device: @retroactive Equatable {
    public static func == (lhs: Device, rhs: Device) -> Bool {
        lhs.id == rhs.id
    }
}
