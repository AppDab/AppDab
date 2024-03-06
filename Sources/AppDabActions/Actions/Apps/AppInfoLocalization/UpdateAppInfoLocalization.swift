import Bagbutik_AppStore
import Bagbutik_Models
import Foundation

/**
 Update an app info localization.

 An app info localization is the localized parts of the App Store listing which isn't tied to a specific version.

 - Parameters:
    - id: The id of the `AppInfoLocalization` to be updated.
    - newName: The new name for the app.
    - newSubtitle: The new subtitle for the app.
    - newPrivacyPolicyUrl: The new URL for the privacy policy.
 - Returns: The updated `AppInfoLocalization`.
 */
@discardableResult
public func updateAppInfoLocalization(withId id: String, newName: String? = nil, newSubtitle: String? = nil, newPrivacyPolicyUrl: String? = nil) async throws -> AppInfoLocalization {
    guard newName != nil || newSubtitle != nil || newPrivacyPolicyUrl != nil else {
        throw AppInfoLocalizationError.noNewValuesSpecified
    }
    let requestBody = AppInfoLocalizationUpdateRequest(data: .init(id: id, attributes: .init(name: newName, privacyPolicyUrl: newPrivacyPolicyUrl, subtitle: newSubtitle)))
    var logValues = [String]()
    if let newName = newName {
        logValues.append("new name '\(newName)'")
    }
    if let newSubtitle = newSubtitle {
        logValues.append("new subtitle '\(newSubtitle)'")
    }
    if let newPrivacyPolicyUrl = newPrivacyPolicyUrl {
        logValues.append("new privacy policy URL '\(newPrivacyPolicyUrl)'")
    }
    ActionsEnvironment.logger.info("🚀 Updating localization with id '\(id)' with \(ListFormatter.localizedString(byJoining: logValues))...")
    let appInfoLocalizationResponse = try await ActionsEnvironment.service.request(.updateAppInfoLocalizationV1(id: id, requestBody: requestBody))
    ActionsEnvironment.logger.info("👍 Localization updated")
    return appInfoLocalizationResponse.data
}

/**
 Update an app info localization.

 An app info localization is the localized parts of the App Store listing which isn't tied to a specific version.

 This will first fetch the app info localizations, and try to figure out the right app info localization id.
 If the app info localization id is already known, use the other overload of this action.

 - Parameters:
    - locale: The locale for which the localization should be updated.
    - appId: The id of the `App` to which this localization is related.
    - newName: The new name for the app.
    - newSubtitle: The new subtitle for the app.
    - newPrivacyPolicyUrl: The new URL for the privacy policy.
 - Returns: The updated `AppInfoLocalization`.
 */
@discardableResult
public func updateAppInfoLocalization(forLocale locale: String, forAppId appId: String, newName: String? = nil, newSubtitle: String? = nil, newPrivacyPolicyUrl: String? = nil) async throws -> AppInfoLocalization {
    ActionsEnvironment.logger.info("🚀 Fetching app info localization by locale '\(locale)' for app id '\(appId)'...")
    let appInfosResponse = try await ActionsEnvironment.service.request(
        .listAppInfosForAppV1(id: appId,
                              fields: [.appInfos([.state, .appInfoLocalizations]),
                                       .appInfoLocalizations([.locale])],
                              includes: [.appInfoLocalizations])
    )
    let appInfoLocalization: AppInfoLocalization? = appInfosResponse.data.compactMap { appInfo -> AppInfoLocalization? in
        guard appInfo.attributes!.state != .readyForDistribution else {
            return nil
        }
        let localizationIds = appInfo.relationships?.appInfoLocalizations?.data?.map(\.id) ?? []
        return appInfosResponse.included?.compactMap { relationship -> AppInfoLocalization? in
            guard case .appInfoLocalization(let localization) = relationship else { return nil }
            return localizationIds.contains(localization.id) ? localization : nil
        }.first
    }.first
    guard let appInfoLocalization = appInfoLocalization else {
        throw AppInfoLocalizationError.appInfoLocalizationForLocaleNotFound
    }
    ActionsEnvironment.logger.info("👍 Found app info localization for locale '\(locale)' (\(appInfoLocalization.id))")
    return try await updateAppInfoLocalization(withId: appInfoLocalization.id, newName: newName, newSubtitle: newSubtitle, newPrivacyPolicyUrl: newPrivacyPolicyUrl)
}
