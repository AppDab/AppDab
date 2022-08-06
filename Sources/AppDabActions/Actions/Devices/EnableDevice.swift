import Bagbutik_Models
import Bagbutik_Provisioning

/**
 Enable a device by its resource id.

 - Parameters:
    - id: The id of the `Device` to enable.
 - Returns: The enabled `Device`.
 */
@discardableResult
public func enableDevice(withId id: String) async throws -> Device {
    let requestBody = DeviceUpdateRequest(data: .init(id: id, attributes: .init(status: .enabled)))
    ActionsEnvironment.logger.info("🚀 Enabling device with id '\(id)'...")
    let deviceResponse = try await ActionsEnvironment.service.request(.updateDeviceV1(id: id, requestBody: requestBody))
    ActionsEnvironment.logger.info("👍 Device enabled")
    return deviceResponse.data
}

/**
 Enable a device by its name.

 - Parameters:
    - name: The name of the `Device` to enable.
 - Returns: The enabled `Device`.
 */
@discardableResult
public func enableDevice(named name: String) async throws -> Device {
    ActionsEnvironment.logger.info("🚀 Fetching device by name '\(name)'...")
    guard let device = try await ActionsEnvironment.service.request(.listDevicesV1(filters: [.name([name])])).data.first else {
        throw DeviceError.deviceWitNameNotFound
    }
    ActionsEnvironment.logger.info("👍 Found device named '\(name)' (\(device.id))")
    return try await enableDevice(withId: device.id)
}
