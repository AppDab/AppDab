import Bagbutik

public func enableDevice(withId id: String) throws {
    let requestBody = DeviceUpdateRequest(data: .init(id: id, attributes: .init(status: .enabled)))
    ActionsEnvironment.logger.info("🚀 Enabling device with id '\(id)'...")
    _ = try ActionsEnvironment.service.requestSynchronously(.updateDevice(id: id, requestBody: requestBody)).get()
    ActionsEnvironment.logger.info("👍 Device enabled")
}

public func enableDevice(named name: String) throws {
    ActionsEnvironment.logger.info("🚀 Fetching device by name '\(name)'...")
    guard let device = try ActionsEnvironment.service.requestSynchronously(.listDevices(filters: [.name([name])])).get().data.first else {
        throw DeviceError.deviceWitNameNotFound
    }
    ActionsEnvironment.logger.info("👍 Found device named '\(name)' (\(device.id))")
    try enableDevice(withId: device.id)
}
