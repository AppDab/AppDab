import Bagbutik

/**
 List all devices.

 - Returns: An array of all the devices.
 */
@discardableResult
public func listDevices() async throws -> [Device] {
    ActionsEnvironment.logger.info("🚀 Fetching list of devices...")
    let response = try await ActionsEnvironment.service.requestAllPages(.listDevices())
    ActionsEnvironment.logger.info("👍 Devices fetched")
    response.data.map(\.attributes).forEach { deviceAttributes in
        let enabledEmoji = deviceAttributes!.status == .enabled ? "🟢" : "🔴"
        ActionsEnvironment.logger.info(" ◦ \(enabledEmoji) \(deviceAttributes!.name!) (\(deviceAttributes!.deviceClass!.prettyName)) - \(deviceAttributes!.udid!)")
    }
    return response.data
}
