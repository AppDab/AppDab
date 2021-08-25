import Bagbutik

public func disableDevice(withId id: String) async throws {
    let requestBody = DeviceUpdateRequest(data: .init(id: id, attributes: .init(status: .disabled)))
    ActionsEnvironment.logger.info("🚀 Disabling device with id '\(id)'...")
    _ = try await ActionsEnvironment.service.request(.updateDevice(id: id, requestBody: requestBody))
    ActionsEnvironment.logger.info("👍 Device disabled")
}

public func disableDevice(named name: String) async throws {
    ActionsEnvironment.logger.info("🚀 Fetching device by name '\(name)'...")
    guard let device = try await ActionsEnvironment.service.request(.listDevices(filters: [.name([name])])).data.first else {
        throw DeviceError.deviceWitNameNotFound
    }
    ActionsEnvironment.logger.info("👍 Found device named '\(name)' (\(device.id))")
    try await disableDevice(withId: device.id)
}
