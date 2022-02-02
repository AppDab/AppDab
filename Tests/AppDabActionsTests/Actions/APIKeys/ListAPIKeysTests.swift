@testable import AppDabActions
import Bagbutik
import Foundation
import XCTest

final class ListAPIKeysTests: ActionsTestCase {
    let valid = try! APIKey(name: "Apple", keyId: "P9M252746H", issuerId: "82067982-6b3b-4a48-be4f-5b10b373c5f2", privateKey: """
    -----BEGIN PRIVATE KEY-----
    MIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQgevZzL1gdAFr88hb2
    OF/2NxApJCzGCEDdfSp6VQO30hyhRANCAAQRWz+jn65BtOMvdyHKcvjBeBSDZH2r
    1RTwjmYSi9R/zpBnuQ4EiMnCqfMPWiZqB4QdbAd0E7oH50VpuZ1P087G
    -----END PRIVATE KEY-----
    """)
    
    let invalidGeneric = GenericPassword(account: "H647252M9P", label: "Epic Games", generic: Data(), value: Data())
    let invalidValue = GenericPassword(account: "H647252M9P", label: "Epic Games", generic: Data("82067982-6b3b-4a48-be4f-5b10b373c5f2".utf8), value: Data())
    
    func testListAPIKeys() throws {
        mockKeychain.genericPasswordsInKeychain = [
            try valid.getGenericPassword(),
        ]
        XCTAssertEqual(try listAPIKeys(), [valid])
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "🔐 Loading list of API Keys from Keychain..."),
            Log(level: .info, message: "👍 API Keys loaded"),
            Log(level: .info, message: " ◦ Apple (P9M252746H)"),
        ])
    }
    
    func testListAPIKeys_InvalidIssuer() throws {
        mockKeychain.genericPasswordsInKeychain = [invalidGeneric]
        XCTAssertThrowsError(try listAPIKeys()) { error in
            XCTAssertEqual(error as! APIKeyError, .invalidAPIKeyFormat)
        }
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "🔐 Loading list of API Keys from Keychain..."),
        ])
    }
    
    func testListAPIKeys_InvalidPrivateKey() throws {
        mockKeychain.genericPasswordsInKeychain = [invalidValue]
        XCTAssertThrowsError(try listAPIKeys()) { error in
            XCTAssertEqual(error as! APIKeyError, .invalidAPIKeyFormat)
        }
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "🔐 Loading list of API Keys from Keychain..."),
        ])
    }
}
