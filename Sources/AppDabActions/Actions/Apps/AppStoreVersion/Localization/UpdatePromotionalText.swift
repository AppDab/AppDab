import Bagbutik

/**
 Update the localized promotional text for an App Store version localization.

 - Parameters:
    - id: The id of the `AppStoreVersionLocalization` to be updated.
    - newPromotionalText: The new promotional text for the App Store version localization.
 - Returns: The updated `AppStoreVersionLocalization`.
 */
@discardableResult
public func updatePromotionalText(
    forAppStoreVersionLocalizationId id: String,
    newPromotionalText: String) async throws -> AppStoreVersionLocalization {
    let requestBody = AppStoreVersionLocalizationUpdateRequest(
        data: .init(id: id, attributes: .init(promotionalText: newPromotionalText)))
    ActionsEnvironment.logger.info("🚀 Updating promotional text for App Store version localization with id '\(id)'...")
    let appStoreVersionLocalizationResponse = try await ActionsEnvironment.service.request(
        .updateAppStoreVersionLocalizationV1(id: id, requestBody: requestBody))
    ActionsEnvironment.logger.info("👍 Promotional text updated")
    return appStoreVersionLocalizationResponse.data
}
