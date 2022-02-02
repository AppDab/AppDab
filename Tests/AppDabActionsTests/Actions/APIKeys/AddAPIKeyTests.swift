@testable import AppDabActions
import Security
import XCTest

final class AddAPIKeyTests: ActionsTestCase {
    let apiKey = try! APIKey(name: "Apple", keyId: "P9M252746H", issuerId: "82067982-6b3b-4a48-be4f-5b10b373c5f2", privateKey: """
    -----BEGIN PRIVATE KEY-----
    MIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQgevZzL1gdAFr88hb2
    OF/2NxApJCzGCEDdfSp6VQO30hyhRANCAAQRWz+jn65BtOMvdyHKcvjBeBSDZH2r
    1RTwjmYSi9R/zpBnuQ4EiMnCqfMPWiZqB4QdbAd0E7oH50VpuZ1P087G
    -----END PRIVATE KEY-----
    """)

    func testAddAPIKey() {
        XCTAssertNoThrow(try addAPIKey(apiKey))
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "🔐 Adding API Key to Keychain..."),
            Log(level: .info, message: "👍 API Key added to Keychain"),
        ])
    }

    func testAddAPIKey_Duplicate() {
        mockKeychain.returnStatusForAdd = errSecDuplicateItem
        XCTAssertThrowsError(try addAPIKey(apiKey)) { error in
            XCTAssertEqual(error as! APIKeyError, .duplicateAPIKey)
        }
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "🔐 Adding API Key to Keychain..."),
        ])
    }

    func testAddAPIKey_Unknown() {
        let status = errSecParam
        mockKeychain.returnStatusForAdd = status
        XCTAssertThrowsError(try addAPIKey(apiKey)) { error in
            XCTAssertEqual(error as! APIKeyError, .failedAddingAPIKey(status))
        }
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "🔐 Adding API Key to Keychain..."),
        ])
    }
}
