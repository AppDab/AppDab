import Bagbutik
import Foundation

@discardableResult
public func updateAppStoreVersionLocalizedTexts(forAppStoreVersionLocalizationId appStoreVersionLocalizationId: String,
                                                description: String? = nil,
                                                keywords: String? = nil,
                                                whatsNew: String? = nil,
                                                promotionalText: String? = nil,
                                                marketingUrl: String? = nil,
                                                supportUrl: String? = nil) async throws -> AppStoreVersionLocalization {
    guard description != nil || keywords != nil || whatsNew != nil || promotionalText != nil
        || marketingUrl != nil || supportUrl != nil else {
        throw AppStoreVersionLocalizationError.noNewValuesSpecified
    }
    var attributes = AppStoreVersionLocalizationUpdateRequest.Data.Attributes()
    var logValues = [String]()
    addAttributesValue(description, keyPath: \.description, attributes: &attributes, name: "description", logValues: &logValues)
    addAttributesValue(keywords, keyPath: \.keywords, attributes: &attributes, name: "keywords", logValues: &logValues)
    addAttributesValue(whatsNew, keyPath: \.whatsNew, attributes: &attributes, name: "what's new", logValues: &logValues)
    addAttributesValue(promotionalText, keyPath: \.promotionalText, attributes: &attributes, name: "promotional text", logValues: &logValues)
    addAttributesValue(marketingUrl, keyPath: \.marketingUrl, attributes: &attributes, name: "marketing URL", logValues: &logValues)
    addAttributesValue(supportUrl, keyPath: \.supportUrl, attributes: &attributes, name: "support URL", logValues: &logValues)
    let requestBody = AppStoreVersionLocalizationUpdateRequest(data: .init(id: appStoreVersionLocalizationId, attributes: attributes))
    ActionsEnvironment.logger.info("🚀 Updating App Store version localization texts with id '\(appStoreVersionLocalizationId)' with \(ListFormatter.localizedString(byJoining: logValues))...")
    let appStoreVersionLocalizationResponse = try await ActionsEnvironment.service.request(
        .updateAppStoreVersionLocalization(id: appStoreVersionLocalizationId, requestBody: requestBody))
    ActionsEnvironment.logger.info("👍 App Store version localization texts updated")
    return appStoreVersionLocalizationResponse.data
}

private func addAttributesValue(_ value: String?, keyPath: WritableKeyPath<AppStoreVersionLocalizationUpdateRequest.Data.Attributes, String?>, attributes: inout AppStoreVersionLocalizationUpdateRequest.Data.Attributes, name: String, logValues: inout [String]) {
    if let value = value {
        attributes[keyPath: keyPath] = value
        logValues.append(name)
    }
}
