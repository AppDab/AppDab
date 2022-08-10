import AppDabActions
import Bagbutik_Models
import Foundation
import XCTest

final class RenameDeviceTests: ActionsTestCase {
    let updateResponse = DeviceResponse(
        data: .init(id: "some-id", links: .init(self: "")),
        links: .init(self: ""))
    
    func testRenameDevice_WithId() async {
        mockBagbutikService.setResponse(updateResponse, for: Endpoint(path: "/v1/devices/some-id", method: .patch))
        let device = try! await renameDevice(withId: "some-id", newName: "Some new name")
        XCTAssertEqual(device, updateResponse.data)
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "🚀 Renaming device with id 'some-id' to 'Some new name'..."),
            Log(level: .info, message: "👍 Device renamed")
        ])
    }
    
    func testRenameDevice_WithName() async {
        let fetchResponse = DevicesResponse(
            data: [.init(id: "some-id", links: .init(self: ""))],
            links: .init(self: ""))
        mockBagbutikService.setResponse(fetchResponse, for: Endpoint(path: "/v1/devices", method: .get))
        mockBagbutikService.setResponse(updateResponse, for: Endpoint(path: "/v1/devices/some-id", method: .patch))
        let device = try! await renameDevice(named: "Some name", newName: "Some new name")
        XCTAssertEqual(device, updateResponse.data)
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "🚀 Fetching device by name 'Some name'..."),
            Log(level: .info, message: "👍 Found device named 'Some name' (some-id)"),
            Log(level: .info, message: "🚀 Renaming device with id 'some-id' to 'Some new name'..."),
            Log(level: .info, message: "👍 Device renamed")
        ])
    }
    
    func testRenameDevice_WithName_NotFound() async {
        let fetchResponse = DevicesResponse(data: [], links: .init(self: ""))
        mockBagbutikService.setResponse(fetchResponse, for: Endpoint(path: "/v1/devices", method: .get))
        await XCTAssertAsyncThrowsError(try await renameDevice(named: "Some name", newName: "Some new name")) { error in
            XCTAssertEqual(error as! DeviceError, .deviceWitNameNotFound)
        }
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "🚀 Fetching device by name 'Some name'..."),
        ])
    }
}
