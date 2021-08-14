import Bagbutik

public func disableDevice(withId id: String) throws {
    let requestBody = DeviceUpdateRequest(data: .init(id: id, attributes: .init(status: .disabled)))
    ActionsEnvironment.logger.info("🚀 Disabling device with id '\(id)'...")
    _ = try ActionsEnvironment.service.requestSynchronously(.updateDevice(id: id, requestBody: requestBody)).get()
    ActionsEnvironment.logger.info("👍 Device disabled")
}

public func disableDevice(named name: String) throws {
    ActionsEnvironment.logger.info("🚀 Fetching device by name '\(name)'...")
    guard let device = try ActionsEnvironment.service.requestSynchronously(.listDevices(filters: [.name([name])])).get().data.first else {
        throw DeviceError.deviceWitNameNotFound
    }
    ActionsEnvironment.logger.info("👍 Found device named '\(name)' (\(device.id))")
    try disableDevice(withId: device.id)
}
