import AppDabActions
import Bagbutik_Models
import Bagbutik_Provisioning
import Foundation
import XCTest

final class RegisterDeviceTests: ActionsTestCase {
    func testRegisterDevice() async {
        let response = DeviceResponse(
            data: .init(id: "some-id", links: .init(self: "")),
            links: .init(self: "")
        )
        mockBagbutikService.setResponse(response, for: Endpoint(path: "/v1/devices", method: .post))
        let device = try! await registerDevice(named: "iFun", platform: .iOS, udid: "some-udid")
        XCTAssertEqual(device, response.data)
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "🚀 Registering a new device called 'iFun' (some-udid) for iOS..."),
            Log(level: .info, message: "👍 Device registered"),
        ])
    }
}
