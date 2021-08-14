import AppDabActions
import Bagbutik
import Foundation
import XCTest

final class RegisterDeviceTests: ActionsTestCase {
    func testRegisterDevice() {
        let response = DeviceResponse(
            data: .init(id: "some-id", links: .init(self: "")),
            links: .init(self: "")
        )
        mockBagbutikService.setResponse(response, for: Endpoint(path: "/v1/devices", method: .post))
        try! registerDevice(named: "iFun", platform: .iOS, udid: "some-udid")
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "🚀 Registering a new device called 'iFun' (some-udid) for iOS..."),
            Log(level: .info, message: "👍 Device registered"),
        ])
    }
}
