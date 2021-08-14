import Bagbutik

public func renameDevice(withId id: String, newName: String) throws {
    let requestBody = DeviceUpdateRequest(data: .init(id: id, attributes: .init(name: newName)))
    ActionsEnvironment.logger.info("🚀 Renaming device with id '\(id)' to '\(newName)'...")
    _ = try ActionsEnvironment.service.requestSynchronously(.updateDevice(id: id, requestBody: requestBody)).get()
    ActionsEnvironment.logger.info("👍 Device renamed")
}

public func renameDevice(named name: String, newName: String) throws {
    ActionsEnvironment.logger.info("🚀 Fetching device by name '\(name)'...")
    guard let device = try ActionsEnvironment.service.requestSynchronously(.listDevices(filters: [.name([name])])).get().data.first else {
        throw DeviceError.deviceWitNameNotFound
    }
    ActionsEnvironment.logger.info("👍 Found device named '\(name)' (\(device.id))")
    try renameDevice(withId: device.id, newName: newName)
}
