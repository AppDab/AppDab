import Bagbutik

public func registerDevice(named name: String, platform: BundleIdPlatform, udid: String) throws {
    let requestBody = DeviceCreateRequest(data: .init(attributes: .init(name: name, platform: platform, udid: udid)))
    ActionsEnvironment.logger.info("🚀 Registering a new device called '\(name)' (\(udid)) for \(platform.prettyName)...")
    _ = try ActionsEnvironment.service.requestSynchronously(.createDevice(requestBody: requestBody)).get()
    ActionsEnvironment.logger.info("👍 Device registered")
}
