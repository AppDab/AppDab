import AppDabActions
import Bagbutik
import Foundation
import XCTest

final class AddCertificateToKeychainTests: ActionsTestCase {
    let base64Certificate = """
    MIIDCDCCAfCgAwIBAgIBATANBgkqhkiG9w0BAQsFADAiMRMwEQYDVQQDDApBcHBEYWJUZXN0MQswCQYDVQQGEwJESzAeFw0yMTA5MTAyMDMxNTRaFw0yMjA5MTAyMDMxNTRaMCIxEzARBgNVBAMMCkFwcERhYlRlc3QxCzAJBgNVBAYTAkRLMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA3CHig1co7vg2loiyBSM+/qbkjgZ/0qA8RaOaXxgkddQEZCKXlgKynKGWYYDlRLpxjGrzCABE9UVxSZb0Ncbx7wvUK029QWgoNTTBmk/eLZECTZRfl9qYjGavCz6lWzlvTd6UVOuSBbVKEe03rPnZbjxJ5DVBvoTcIl6mVrOK9fBQIRXlZ4ZSRviKM99ZejePy94FsvDHnXJ3like3IQ5TEzRcFiv/9xD6zRnQEN7MpnV6SBVky/O5MeXA4DHTHKjaypV33T+OzBfoYkEe/6kx2uiFcWUO7tVjYQTruW5fohyRkVyJfFWBHx0Ybx1jSPV2tIzDhYna4LtiClAVaXXvwIDAQABo0kwRzAOBgNVHQ8BAf8EBAMCB4AwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwMwHQYDVR0OBBYEFC/B+S6AZ7CIFMpCDNk7o3u1FhBBMA0GCSqGSIb3DQEBCwUAA4IBAQCQT9Bx5eu8ty9fdoSdDFtYacHlquioiwDOuCucSjtzR2x1+mO7zHGWdBOB7f0EiVmK5F1oN/WeMdaSbxJbeZVrTWMvPpRgT9++J6YpcRzWIuTc9SRZqY6gm20L32RwH6AwEgizCkzAXGXRVwBHZyzlBJ4n/wi/8ou/DJ23uZjUF1fm3MBshyXrtC7GmWma6sRgU0tV52t7NHFv58jLWJInXNhy/OfpbmLiVOfb9dPOW79v9vbCAgrxLX4PWjk5jLmJI0AvSDaCQ/Ojmcq+UYwsPdtFkTl2lIXMJ6SHyuSnz82VeZXCh4FTNAHgGHrQJoCGk0bFt6EyYn4qe/Ooyrke
    """

    func testAddCertificateToKeychain() {
        let certificate = Certificate(id: "some-id", links: .init(self: ""), attributes: .init(certificateContent: base64Certificate, name: "AppDabTest"))
        XCTAssertNoThrow(try addCertificateToKeychain(certificate: certificate))
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "🔐 Adding certificate to Keychain..."),
            Log(level: .info, message: "👍 Certificate added to Keychain"),
        ])
    }

    func testAddCertificateToKeychain_OnlyValues() {
        XCTAssertNoThrow(try addCertificateToKeychain(named: "AppDabTest", certificateContent: base64Certificate))
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "🔐 Adding certificate to Keychain..."),
            Log(level: .info, message: "👍 Certificate added to Keychain"),
        ])
    }

    func testAddCertificateToKeychain_MissingName() {
        let certificate = Certificate(id: "some-id", links: .init(self: ""), attributes: .init(certificateContent: base64Certificate))
        XCTAssertThrowsError(try addCertificateToKeychain(certificate: certificate)) { error in
            XCTAssertEqual(error as! AddCertificateToKeychainError, .invalidOnlineCertificateData)
        }
        XCTAssertEqual(mockLogHandler.logs, [Log(level: .info, message: "🔐 Adding certificate to Keychain...")])
    }

    func testAddCertificateToKeychain_InvalidData() {
        let certificate = Certificate(id: "some-id", links: .init(self: ""), attributes: .init(certificateContent: "invalid", name: "AppDabTest"))
        XCTAssertThrowsError(try addCertificateToKeychain(certificate: certificate)) { error in
            XCTAssertEqual(error as! AddCertificateToKeychainError, .invalidOnlineCertificateData)
        }
        XCTAssertEqual(mockLogHandler.logs, [Log(level: .info, message: "🔐 Adding certificate to Keychain...")])
    }

    func testAddCertificateToKeychain_KeychainError() {
        mockKeychain.returnStatusForAdd = errSecParam
        let certificate = Certificate(id: "some-id", links: .init(self: ""), attributes: .init(certificateContent: base64Certificate, name: "AppDabTest"))
        XCTAssertThrowsError(try addCertificateToKeychain(certificate: certificate)) { error in
            XCTAssertEqual(error as! AddCertificateToKeychainError, .errorAddingCertificateToKeychain(status: errSecParam))
        }
        XCTAssertEqual(mockLogHandler.logs, [Log(level: .info, message: "🔐 Adding certificate to Keychain...")])
    }
}
