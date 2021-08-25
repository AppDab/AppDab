import Bagbutik

public func registerDevice(named name: String, platform: BundleIdPlatform, udid: String) async throws {
    let requestBody = DeviceCreateRequest(data: .init(attributes: .init(name: name, platform: platform, udid: udid)))
    ActionsEnvironment.logger.info("🚀 Registering a new device called '\(name)' (\(udid)) for \(platform.prettyName)...")
    _ = try await ActionsEnvironment.service.request(.createDevice(requestBody: requestBody))
    ActionsEnvironment.logger.info("👍 Device registered")
}
