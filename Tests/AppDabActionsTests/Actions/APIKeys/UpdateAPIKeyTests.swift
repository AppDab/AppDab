import AppDabActions
import Security
import XCTest

final class UpdateAPIKeyTests: ActionsTestCase {
    let apiKey = try! APIKey(name: "Apple", keyId: "P9M252746H", issuerId: "82067982-6b3b-4a48-be4f-5b10b373c5f2", privateKey: """
    -----BEGIN PRIVATE KEY-----
    MIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQgevZzL1gdAFr88hb2
    OF/2NxApJCzGCEDdfSp6VQO30hyhRANCAAQRWz+jn65BtOMvdyHKcvjBeBSDZH2r
    1RTwjmYSi9R/zpBnuQ4EiMnCqfMPWiZqB4QdbAd0E7oH50VpuZ1P087G
    -----END PRIVATE KEY-----
    """)

    func testUpdateAPIKey() {
        XCTAssertNoThrow(try updateAPIKey(apiKey, forKeyId: apiKey.keyId))
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "🔐 Updating API Key 'P9M252746H' in Keychain..."),
            Log(level: .info, message: "👍 API Key updated in Keychain"),
        ])
    }
}
