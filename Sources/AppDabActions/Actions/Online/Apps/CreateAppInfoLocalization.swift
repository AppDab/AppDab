import Bagbutik
import Foundation

@discardableResult
public func createAppInfoLocalization(forLocale locale: String, forAppInfoId appInfoId: String, name: String? = nil, subtitle: String? = nil, privacyPolicyUrl: String? = nil) async throws -> AppInfoLocalization {
    guard name != nil || subtitle != nil || privacyPolicyUrl != nil else {
        throw AppInfoLocalizationError.noNewValuesSpecified
    }
    let requestBody = AppInfoLocalizationCreateRequest(data: .init(
        attributes: .init(locale: locale, name: name, privacyChoicesUrl: nil, privacyPolicyText: nil, privacyPolicyUrl: privacyPolicyUrl, subtitle: subtitle),
        relationships: .init(appInfo: .init(data: .init(id: appInfoId)))
    ))
    var logValues = [String]()
    if let name = name {
        logValues.append("name '\(name)'")
    }
    if let subtitle = subtitle {
        logValues.append("subtitle '\(subtitle)'")
    }
    if let privacyPolicyUrl = privacyPolicyUrl {
        logValues.append("privacy policy URL '\(privacyPolicyUrl)'")
    }
    ActionsEnvironment.logger.info("🚀 Create localization with \(ListFormatter.localizedString(byJoining: logValues))...")
    let appInfoLocalizationResponse = try await ActionsEnvironment.service.request(.createAppInfoLocalization(requestBody: requestBody))
    ActionsEnvironment.logger.info("👍 Localization created")
    return appInfoLocalizationResponse.data
}

@discardableResult
public func createAppInfoLocalization(forLocale locale: String, forAppId appId: String, name: String? = nil, subtitle: String? = nil, privacyPolicyUrl: String? = nil) async throws -> AppInfoLocalization {
    ActionsEnvironment.logger.info("🚀 Fetching app info for app id '\(appId)'...")
    let appInfosResponse = try await ActionsEnvironment.service.request(
        .listAppInfosForApp(id: appId, fields: [.appInfos([.appStoreState])], includes: [.appInfoLocalizations])
    )
    let appInfo: AppInfo = appInfosResponse.data.first { appInfo in
        appInfo.attributes!.appStoreState != .readyForSale &&
            appInfo.attributes!.appStoreState != .preorderReadyForSale
    }!
    ActionsEnvironment.logger.info("👍 Found app info for app id '\(appId)' (\(appInfo.id))")
    return try await createAppInfoLocalization(forLocale: locale, forAppInfoId: appInfo.id, name: name, subtitle: subtitle, privacyPolicyUrl: privacyPolicyUrl)
}
