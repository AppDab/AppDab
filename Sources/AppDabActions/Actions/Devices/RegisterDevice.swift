import Bagbutik

/**
 Register a device for testing.

 - Parameters:
    - name: The name of the device.
    - platform: The platform of the device.
    - udid: The UDID of the device.
 - Returns: The newly registered `Device`.
 */
@discardableResult
public func registerDevice(named name: String, platform: BundleIdPlatform, udid: String) async throws -> Device {
    let requestBody = DeviceCreateRequest(data: .init(attributes: .init(name: name, platform: platform, udid: udid)))
    ActionsEnvironment.logger.info("🚀 Registering a new device called '\(name)' (\(udid)) for \(platform.prettyName)...")
    let deviceResponse = try await ActionsEnvironment.service.request(.createDevice(requestBody: requestBody))
    ActionsEnvironment.logger.info("👍 Device registered")
    return deviceResponse.data
}
