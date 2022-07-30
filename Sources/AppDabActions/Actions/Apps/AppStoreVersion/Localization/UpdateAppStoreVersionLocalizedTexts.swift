import Bagbutik
import Foundation

/**
 Update the localized texts for an App Store version.

 - Parameters:
    - id: The id of the `AppStoreVersionLocalization` to be updated.
    - newDescription: The new description for the App Store version localization.
    - newKeywords: The new keywords for the App Store version localization.
    - newWhatsNew: The new "What's new" text for the App Store version localization.
    - newPromotionalText: The new promotional text for the App Store version localization.
    - newMarketingUrl: The new marketing URL for the App Store version localization.
    - newSupportUrl: The new support URL for the App Store version localization.
 - Returns: The updated `AppStoreVersionLocalization`.
 */
@discardableResult
public func updateAppStoreVersionLocalizedTexts(forAppStoreVersionLocalizationId id: String,
                                                newDescription: String? = nil,
                                                newKeywords: String? = nil,
                                                newWhatsNew: String? = nil,
                                                newPromotionalText: String? = nil,
                                                newMarketingUrl: String? = nil,
                                                newSupportUrl: String? = nil) async throws -> AppStoreVersionLocalization {
    guard newDescription != nil || newKeywords != nil || newWhatsNew != nil || newPromotionalText != nil
        || newMarketingUrl != nil || newSupportUrl != nil else {
        throw AppStoreVersionLocalizationError.noNewValuesSpecified
    }
    var attributes = AppStoreVersionLocalizationUpdateRequest.Data.Attributes()
    var logValues = [String]()
    addAttributesValue(newDescription, keyPath: \.description, attributes: &attributes, name: "description", logValues: &logValues)
    addAttributesValue(newKeywords, keyPath: \.keywords, attributes: &attributes, name: "keywords", logValues: &logValues)
    addAttributesValue(newWhatsNew, keyPath: \.whatsNew, attributes: &attributes, name: "what's new", logValues: &logValues)
    addAttributesValue(newPromotionalText, keyPath: \.promotionalText, attributes: &attributes, name: "promotional text", logValues: &logValues)
    addAttributesValue(newMarketingUrl, keyPath: \.marketingUrl, attributes: &attributes, name: "marketing URL", logValues: &logValues)
    addAttributesValue(newSupportUrl, keyPath: \.supportUrl, attributes: &attributes, name: "support URL", logValues: &logValues)
    let requestBody = AppStoreVersionLocalizationUpdateRequest(data: .init(id: id, attributes: attributes))
    ActionsEnvironment.logger.info("🚀 Updating App Store version localization texts with id '\(id)' with \(ListFormatter.localizedString(byJoining: logValues))...")
    let appStoreVersionLocalizationResponse = try await ActionsEnvironment.service.request(
        .updateAppStoreVersionLocalizationV1(id: id, requestBody: requestBody))
    ActionsEnvironment.logger.info("👍 App Store version localization texts updated")
    return appStoreVersionLocalizationResponse.data
}

private func addAttributesValue(_ value: String?, keyPath: WritableKeyPath<AppStoreVersionLocalizationUpdateRequest.Data.Attributes, String?>, attributes: inout AppStoreVersionLocalizationUpdateRequest.Data.Attributes, name: String, logValues: inout [String]) {
    if let value = value {
        attributes[keyPath: keyPath] = value
        logValues.append(name)
    }
}
