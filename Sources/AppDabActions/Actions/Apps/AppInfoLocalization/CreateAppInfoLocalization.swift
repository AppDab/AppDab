import Bagbutik_AppStore
import Bagbutik_Models
import Foundation

/**
 Create an app info localization for locale.

 An app info localization is the localized parts of the App Store listing which isn't tied to a specific version.

 - Parameters:
    - locale: The locale for which the localization should be created.
    - appInfoId: The id of the `AppInfo` to which this localization is related.
    - name: The name of the app in this locale.
    - subtitle: The subtitle for the app in this locale.
    - privacyPolicyUrl: The URL for the privacy policy in this locale.
 - Returns: The newly created `AppInfoLocalization`.
 */
@discardableResult
public func createAppInfoLocalization(forLocale locale: String, forAppInfoId appInfoId: String, name: String? = nil, subtitle: String? = nil, privacyPolicyUrl: String? = nil) async throws -> AppInfoLocalization {
    guard let name, subtitle != nil || privacyPolicyUrl != nil else {
        throw AppInfoLocalizationError.noNewValuesSpecified
    }
    let requestBody = AppInfoLocalizationCreateRequest(data: .init(
        attributes: .init(locale: locale, name: name, privacyChoicesUrl: nil, privacyPolicyText: nil, privacyPolicyUrl: privacyPolicyUrl, subtitle: subtitle),
        relationships: .init(appInfo: .init(data: .init(id: appInfoId)))
    ))
    var logValues = [String]()
    logValues.append("name '\(name)'")
    if let subtitle {
        logValues.append("subtitle '\(subtitle)'")
    }
    if let privacyPolicyUrl {
        logValues.append("privacy policy URL '\(privacyPolicyUrl)'")
    }
    ActionsEnvironment.logger.info("🚀 Create localization with \(ListFormatter.localizedString(byJoining: logValues))...")
    let appInfoLocalizationResponse = try await ActionsEnvironment.service.request(.createAppInfoLocalizationV1(requestBody: requestBody))
    ActionsEnvironment.logger.info("👍 Localization created")
    return appInfoLocalizationResponse.data
}

/**
 Create an app info localization for locale.

 An app info localization is the localized parts of the App Store listing which isn't tied to a specific version.

 This will first fetch the app infos, and try to figure out the right app info id.
 If the app info id is already known, use the other overload of this action.

 - Parameters:
    - locale: The locale for which the localization should be created.
    - appId: The id of the `App` to which this localization is related.
    - name: The name of the app in this locale.
    - subtitle: The subtitle for the app in this locale.
    - privacyPolicyUrl: The URL for the privacy policy in this locale.
 - Returns: The newly created `AppInfoLocalization`.
 */
@discardableResult
public func createAppInfoLocalization(forLocale locale: String, forAppId appId: String, name: String? = nil, subtitle: String? = nil, privacyPolicyUrl: String? = nil) async throws -> AppInfoLocalization {
    ActionsEnvironment.logger.info("🚀 Fetching app info for app id '\(appId)'...")
    let appInfosResponse = try await ActionsEnvironment.service.request(
        .listAppInfosForAppV1(id: appId, fields: [.appInfos([.state])], includes: [.appInfoLocalizations])
    )
    let appInfo: AppInfo = appInfosResponse.data.first { appInfo in
        appInfo.attributes!.state != .readyForDistribution
    }!
    ActionsEnvironment.logger.info("👍 Found app info for app id '\(appId)' (\(appInfo.id))")
    return try await createAppInfoLocalization(forLocale: locale, forAppInfoId: appInfo.id, name: name, subtitle: subtitle, privacyPolicyUrl: privacyPolicyUrl)
}
