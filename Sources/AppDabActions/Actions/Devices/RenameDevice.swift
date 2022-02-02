import Bagbutik

@discardableResult
public func renameDevice(withId id: String, newName: String) async throws -> Device {
    let requestBody = DeviceUpdateRequest(data: .init(id: id, attributes: .init(name: newName)))
    ActionsEnvironment.logger.info("🚀 Renaming device with id '\(id)' to '\(newName)'...")
    let deviceResponse = try await ActionsEnvironment.service.request(.updateDevice(id: id, requestBody: requestBody))
    ActionsEnvironment.logger.info("👍 Device renamed")
    return deviceResponse.data
}

@discardableResult
public func renameDevice(named name: String, newName: String) async throws -> Device {
    ActionsEnvironment.logger.info("🚀 Fetching device by name '\(name)'...")
    guard let device = try await ActionsEnvironment.service.request(.listDevices(filters: [.name([name])])).data.first else {
        throw DeviceError.deviceWitNameNotFound
    }
    ActionsEnvironment.logger.info("👍 Found device named '\(name)' (\(device.id))")
    return try await renameDevice(withId: device.id, newName: newName)
}
