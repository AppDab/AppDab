import AppDabActions
import Bagbutik
import Foundation
import XCTest

final class RenameDeviceTests: ActionsTestCase {
    func testRenameDevice() {
        let fetchResponse = DevicesResponse(
            data: [.init(id: "some-id", links: .init(self: ""))],
            links: .init(self: ""))
        let updateResponse = DeviceResponse(
            data: .init(id: "some-id", links: .init(self: "")),
            links: .init(self: ""))
        mockBagbutikService.setResponse(fetchResponse, for: Endpoint(path: "/v1/devices", method: .get))
        mockBagbutikService.setResponse(updateResponse, for: Endpoint(path: "/v1/devices/some-id", method: .patch))
        try! renameDevice(named: "Some name", newName: "Some new name")
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "🚀 Fetching device by name 'Some name'..."),
            Log(level: .info, message: "👍 Found device named 'Some name' (some-id)"),
            Log(level: .info, message: "🚀 Renaming device with id 'some-id' to 'Some new name'..."),
            Log(level: .info, message: "👍 Device renamed")
        ])
    }
    
    func testEnalbeDevice_WithName_NotFound() {
        let fetchResponse = DevicesResponse(data: [], links: .init(self: ""))
        mockBagbutikService.setResponse(fetchResponse, for: Endpoint(path: "/v1/devices", method: .get))
        XCTAssertThrowsError(try renameDevice(named: "Some name", newName: "Some new name")) { error in
            XCTAssertEqual(error as! DeviceError, .deviceWitNameNotFound)
        }
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "🚀 Fetching device by name 'Some name'..."),
        ])
    }
}
