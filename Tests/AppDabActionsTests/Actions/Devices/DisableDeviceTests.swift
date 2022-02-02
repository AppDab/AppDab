import AppDabActions
import Bagbutik
import Foundation
import XCTest

final class DisableDeviceTests: ActionsTestCase {
    let updateResponse = DeviceResponse(
        data: .init(id: "some-id", links: .init(self: "")),
        links: .init(self: ""))
    
    func testDisableDevice_WithId() async {
        mockBagbutikService.setResponse(updateResponse, for: Endpoint(path: "/v1/devices/some-id", method: .patch))
        let device = try! await disableDevice(withId: "some-id")
        XCTAssertEqual(device, updateResponse.data)
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "🚀 Disabling device with id 'some-id'..."),
            Log(level: .info, message: "👍 Device disabled")
        ])
    }
    
    func testDisableDevice_WithName() async {
        let fetchResponse = DevicesResponse(
            data: [.init(id: "some-id", links: .init(self: ""))],
            links: .init(self: ""))
        mockBagbutikService.setResponse(fetchResponse, for: Endpoint(path: "/v1/devices", method: .get))
        mockBagbutikService.setResponse(updateResponse, for: Endpoint(path: "/v1/devices/some-id", method: .patch))
        let device = try! await disableDevice(named: "Some name")
        XCTAssertEqual(device, updateResponse.data)
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "🚀 Fetching device by name 'Some name'..."),
            Log(level: .info, message: "👍 Found device named 'Some name' (some-id)"),
            Log(level: .info, message: "🚀 Disabling device with id 'some-id'..."),
            Log(level: .info, message: "👍 Device disabled")
        ])
    }
    
    func testDisableDevice_WithName_NotFound() async {
        let fetchResponse = DevicesResponse(data: [], links: .init(self: ""))
        mockBagbutikService.setResponse(fetchResponse, for: Endpoint(path: "/v1/devices", method: .get))
        await XCTAssertAsyncThrowsError(try await disableDevice(named: "Some name")) { error in
            XCTAssertEqual(error as! DeviceError, .deviceWitNameNotFound)
        }
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "🚀 Fetching device by name 'Some name'..."),
        ])
    }
}
