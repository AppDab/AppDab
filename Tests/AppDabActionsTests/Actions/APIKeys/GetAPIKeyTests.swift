@testable import AppDabActions
import Bagbutik
import Foundation
import XCTest

final class GetAPIKeyTests: ActionsTestCase {
    let apiKey = try! APIKey(name: "Apple", keyId: "P9M252746H", issuerId: "82067982-6b3b-4a48-be4f-5b10b373c5f2", privateKey: """
    -----BEGIN PRIVATE KEY-----
    MIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQgevZzL1gdAFr88hb2
    OF/2NxApJCzGCEDdfSp6VQO30hyhRANCAAQRWz+jn65BtOMvdyHKcvjBeBSDZH2r
    1RTwjmYSi9R/zpBnuQ4EiMnCqfMPWiZqB4QdbAd0E7oH50VpuZ1P087G
    -----END PRIVATE KEY-----
    """)
    let invalidApiKey = GenericPassword(account: "H647252M9P", label: "Epic Games", generic: Data(), value: Data())
    
    func testGetAPIKey() throws {
        mockKeychain.genericPasswordsInKeychain = [
            try apiKey.getGenericPassword(),
        ]
        XCTAssertEqual(try getAPIKey(withId: apiKey.keyId), apiKey)
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "🔐 Getting API Key with id '\(apiKey.keyId)' from Keychain..."),
            Log(level: .info, message: "👍 Got API Key: \(apiKey.name) (\(apiKey.keyId))"),
        ])
    }
    
    func testGetAPIKey_NotInKeychain() throws {
        mockKeychain.genericPasswordsInKeychain = []
        XCTAssertThrowsError(try getAPIKey(withId: apiKey.keyId)) { error in
            XCTAssertEqual(error as! APIKeyError, .apiKeyNotInKeychain(apiKey.keyId))
        }
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "🔐 Getting API Key with id '\(apiKey.keyId)' from Keychain..."),
        ])
    }
    
    func testGetAPIKey_InvalidGenericPassword() throws {
        mockKeychain.genericPasswordsInKeychain = [invalidApiKey]
        XCTAssertThrowsError(try getAPIKey(withId: invalidApiKey.account)) { error in
            XCTAssertEqual(error as! APIKeyError, .invalidAPIKeyFormat)
        }
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "🔐 Getting API Key with id '\(invalidApiKey.account)' from Keychain..."),
        ])
    }
}
