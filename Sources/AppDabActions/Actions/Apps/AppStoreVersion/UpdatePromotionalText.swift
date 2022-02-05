import Bagbutik

@discardableResult
public func updatePromotionalText(forAppStoreVersionLocalizationId appStoreVersionLocalizationId: String,
                                  promotionalText: String) async throws -> AppStoreVersionLocalization {
    let requestBody = AppStoreVersionLocalizationUpdateRequest(data: .init(id: appStoreVersionLocalizationId,
                                                                           attributes: .init(promotionalText: promotionalText)))
    ActionsEnvironment.logger.info("🚀 Updating promotional text for App Store version localization with id '\(appStoreVersionLocalizationId)'...")
    let appStoreVersionLocalizationResponse = try await ActionsEnvironment.service.request(
        .updateAppStoreVersionLocalization(id: appStoreVersionLocalizationId, requestBody: requestBody))
    ActionsEnvironment.logger.info("👍 Promotional text updated")
    return appStoreVersionLocalizationResponse.data
}
