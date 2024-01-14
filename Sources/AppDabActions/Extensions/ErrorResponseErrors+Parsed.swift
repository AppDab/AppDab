import Bagbutik_Core
import Bagbutik_Models
import Foundation

internal extension ErrorResponse.Errors {
    var parsedDetail: String {
        if code.hasPrefix("STATE_ERROR.ENTITY_STATE_INVALID") {
            return "The action could not be completed, because the item is not in a valid state."
        } else if code.hasPrefix("STATE_ERROR.SCREENSHOT_REQUIRED."),
                  let displayType = ScreenshotDisplayType(rawValue: String(code.split(separator: ".")[2])) {
            return "A required screenshot is missing: \(displayType.prettyName)"
        } else if code.hasPrefix("ENTITY_ERROR.ATTRIBUTE.REQUIRED"),
                  case .jsonPointer(let jsonPointer) = source,
                  let pointer = jsonPointer.pointer,
                  pointer.hasPrefix("/data/attributes/") {
            let attributeName = String(pointer.suffix(from: .init(utf16Offset: 17, in: pointer)))
            return "A required value is missing: \(attributeName.camelCasedToTitleCased.magicWordsFixed)"
        } else if code.hasPrefix("ENTITY_ERROR.RELATIONSHIP.INVALID"),
                  case .jsonPointer(let jsonPointer) = source,
                  let pointer = jsonPointer.pointer,
                  pointer.hasPrefix("/data/relationships/") {
            let relationshipName = String(pointer.suffix(from: .init(utf16Offset: 20, in: pointer)))
            return "A associated type is missing or invalid: \(relationshipName.camelCasedToTitleCased.magicWordsFixed)"
        }
        return detail ?? title
    }
}

private extension String {
    var camelCasedToTitleCased: String {
        unicodeScalars.reduce("") {
            if CharacterSet.uppercaseLetters.contains($1) {
                if $0.count > 0 {
                    return ($0 + " " + String($1))
                }
            }
            return $0 + String($1)
        }
        .capitalized
    }

    var magicWordsFixed: String {
        replacingOccurrences(of: "Url", with: "URL")
    }
}

extension ScreenshotDisplayType {
    var prettyName: String {
        switch self {
        case .appIphone67:
            return #"iPhone 6.7" Display"#
        case .appIphone65:
            return #"iPhone 6.5" Display"#
        case .appIphone61:
            return #"iPhone 6.1" Display"#
        case .appIphone58:
            return #"iPhone 5.8" Display"#
        case .appIphone55:
            return #"iPhone 5.5" Display"#
        case .appIphone47:
            return #"iPhone 4.7" Display"#
        case .appIphone40:
            return #"iPhone 4" Display"#
        case .appIphone35:
            return #"iPhone 3.5" Display"#
        case .appIpadPro3Gen129:
            return #"iPad Pro (3rd Gen) 12.9" Display"#
        case .appIpadPro3Gen11:
            return #"iPad 11" Display"#
        case .appIpadPro129:
            return #"iPad Pro (2nd Gen) 12.9" Display"#
        case .appIpad105:
            return #"iPad 10.5" Display"#
        case .appIpad97:
            return #"iPad 9.7" Display"#
        case .appDesktop:
            return "Mac"
        case .appWatchUltra:
            return "Apple Watch Ultra"
        case .appWatchSeries7:
            return "Apple Watch Series 7"
        case .appWatchSeries4:
            return "Apple Watch Series 4"
        case .appWatchSeries3:
            return "Apple Watch Series 3"
        case .appAppleTV:
            return "Apple TV"
        case .appAppleVisionPro:
            return "Apple Vision Pro"
        case .iMessageAppIphone67:
            return #"iPhone 6.7" Display"#
        case .iMessageAppIphone65:
            return #"iPhone 6.5" Display"#
        case .iMessageAppIphone61:
            return #"iPhone 6.1" Display"#
        case .iMessageAppIphone58:
            return #"iPhone 5.8" Display"#
        case .iMessageAppIphone55:
            return #"iPhone 5.5" Display"#
        case .iMessageAppIphone47:
            return #"iPhone 4.7" Display"#
        case .iMessageAppIphone40:
            return #"iPhone 4" Display"#
        case .iMessageAppIpadPro3Gen129:
            return #"iPad Pro (3rd Gen) 12.9" Display"#
        case .iMessageAppIpadPro3Gen11:
            return #"iPad 11" Display"#
        case .iMessageAppIpadPro129:
            return #"iPad Pro (2nd Gen) 12.9" Display"#
        case .iMessageAppIpad105:
            return #"iPad 10.5" Display"#
        case .iMessageAppIpad97:
            return #"iPad 9.7" Display"#
        }
    }
}
