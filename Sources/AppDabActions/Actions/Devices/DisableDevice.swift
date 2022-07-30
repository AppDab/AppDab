import Bagbutik

/**
 Disable a device by its resource id.

 - Parameters:
    - id: The id of the `Device` to disable.
 - Returns: The disabled `Device`.
 */
@discardableResult
public func disableDevice(withId id: String) async throws -> Device {
    let requestBody = DeviceUpdateRequest(data: .init(id: id, attributes: .init(status: .disabled)))
    ActionsEnvironment.logger.info("🚀 Disabling device with id '\(id)'...")
    let deviceResponse = try await ActionsEnvironment.service.request(.updateDeviceV1(id: id, requestBody: requestBody))
    ActionsEnvironment.logger.info("👍 Device disabled")
    return deviceResponse.data
}

/**
 Disable a device by its name.

 - Parameters:
    - name: The name of the `Device` to disable.
 - Returns: The disabled `Device`.
 */
@discardableResult
public func disableDevice(named name: String) async throws -> Device {
    ActionsEnvironment.logger.info("🚀 Fetching device by name '\(name)'...")
    guard let device = try await ActionsEnvironment.service.request(.listDevicesV1(filters: [.name([name])])).data.first else {
        throw DeviceError.deviceWitNameNotFound
    }
    ActionsEnvironment.logger.info("👍 Found device named '\(name)' (\(device.id))")
    return try await disableDevice(withId: device.id)
}
