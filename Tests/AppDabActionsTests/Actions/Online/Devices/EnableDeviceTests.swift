import AppDabActions
import Bagbutik
import Foundation
import XCTest

final class EnableDeviceTests: ActionsTestCase {
    func testEnableDevice() {
        let fetchResponse = DevicesResponse(
            data: [.init(id: "some-id", links: .init(self: ""))],
            links: .init(self: ""))
        let updateResponse = DeviceResponse(
            data: .init(id: "some-id", links: .init(self: "")),
            links: .init(self: ""))
        mockBagbutikService.setResponse(fetchResponse, for: Endpoint(path: "/v1/devices", method: .get))
        mockBagbutikService.setResponse(updateResponse, for: Endpoint(path: "/v1/devices/some-id", method: .patch))
        try! enableDevice(named: "Some name")
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "🚀 Fetching device by name 'Some name'..."),
            Log(level: .info, message: "👍 Found device named 'Some name' (some-id)"),
            Log(level: .info, message: "🚀 Enabling device with id 'some-id'..."),
            Log(level: .info, message: "👍 Device enabled")
        ])
    }
    
    func testEnalbeDevice_WithName_NotFound() {
        let fetchResponse = DevicesResponse(data: [], links: .init(self: ""))
        mockBagbutikService.setResponse(fetchResponse, for: Endpoint(path: "/v1/devices", method: .get))
        XCTAssertThrowsError(try enableDevice(named: "Some name")) { error in
            XCTAssertEqual(error as! DeviceError, .deviceWitNameNotFound)
        }
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "🚀 Fetching device by name 'Some name'..."),
        ])
    }
}
