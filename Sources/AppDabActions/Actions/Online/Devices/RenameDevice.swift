import Bagbutik

public func renameDevice(withId id: String, newName: String) async throws {
    let requestBody = DeviceUpdateRequest(data: .init(id: id, attributes: .init(name: newName)))
    ActionsEnvironment.logger.info("🚀 Renaming device with id '\(id)' to '\(newName)'...")
    _ = try await ActionsEnvironment.service.request(.updateDevice(id: id, requestBody: requestBody))
    ActionsEnvironment.logger.info("👍 Device renamed")
}

public func renameDevice(named name: String, newName: String) async throws {
    ActionsEnvironment.logger.info("🚀 Fetching device by name '\(name)'...")
    guard let device = try await ActionsEnvironment.service.request(.listDevices(filters: [.name([name])])).data.first else {
        throw DeviceError.deviceWitNameNotFound
    }
    ActionsEnvironment.logger.info("👍 Found device named '\(name)' (\(device.id))")
    try await renameDevice(withId: device.id, newName: newName)
}
