import AppDabActions
import XCTest

final class DeviceErrorTests: XCTestCase {
    func testDeviceErrorDescription() {
        XCTAssertEqual(DeviceError.deviceWitNameNotFound.description, "Device with name not found")
    }
}
