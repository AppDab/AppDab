import Bagbutik
import Foundation

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
    ActionsEnvironment.logger.info("🚀 Update localization with id '\(id)' with \(ListFormatter.localizedString(byJoining: logValues))...")
    let appInfoLocalizationResponse = try await ActionsEnvironment.service.request(.updateAppInfoLocalization(id: id, requestBody: requestBody))
    ActionsEnvironment.logger.info("👍 Localization updated")
    return appInfoLocalizationResponse.data
}

@discardableResult
public func updateAppInfoLocalization(forLocale locale: String, forAppId appId: String, newName: String? = nil, newSubtitle: String? = nil, newPrivacyPolicyUrl: String? = nil) async throws -> AppInfoLocalization {
    ActionsEnvironment.logger.info("🚀 Fetching app info localization by locale '\(locale)' for app id '\(appId)'...")
    let appInfosResponse = try await ActionsEnvironment.service.request(
        .listAppInfosForApp(id: appId,
                            fields: [.appInfos([.appStoreState, .appInfoLocalizations]),
                                     .appInfoLocalizations([.locale])],
                            includes: [.appInfoLocalizations])
    )
    let appInfoLocalization: AppInfoLocalization? = appInfosResponse.data.compactMap { appInfo -> AppInfoLocalization? in
        guard appInfo.attributes!.appStoreState != .readyForSale,
              appInfo.attributes!.appStoreState != .preorderReadyForSale
        else {
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
