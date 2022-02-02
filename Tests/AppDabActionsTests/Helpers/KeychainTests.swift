@testable import AppDabActions
import XCTest

final class KeychainTests: XCTestCase {
    func testReadP12Passphrase() {
        let passphrase = "my-passphrase"
        let keychain = Keychain(secItemCopyMatching: { query, result in
            let service = (query as! [String: Any])[kSecAttrService as String] as! String
            XCTAssertEqual(service, "AppDab certificate some-serial")
            result?.pointee = [kSecValueData as String: passphrase.data(using: .utf8)!] as CFTypeRef
            return errSecSuccess
        })
        XCTAssertEqual(try keychain.readP12Passphrase(certificateSerialNumber: "some-serial"), passphrase)
    }

    func testReadP12Passphrase_NoPasswordFound() {
        let keychain = Keychain(secItemCopyMatching: { _, _ in errSecItemNotFound })
        XCTAssertThrowsError(try keychain.readP12Passphrase(certificateSerialNumber: "some-serial")) { error in
            XCTAssertEqual(error as! KeychainError, .noPasswordFound)
        }
    }

    func testReadP12Passphrase_UnknownStatus() {
        let keychain = Keychain(secItemCopyMatching: { _, _ in errSecNoSuchAttr })
        XCTAssertThrowsError(try keychain.readP12Passphrase(certificateSerialNumber: "some-serial")) { error in
            XCTAssertEqual(error as! KeychainError, .unknown(status: errSecNoSuchAttr))
        }
    }

    func testSaveP12Passphrase() {
        let keychain = Keychain(secItemAdd: { query, _ in
            let service = (query as! [String: Any])[kSecAttrService as String] as! String
            XCTAssertEqual(service, "AppDab certificate some-serial")
            return errSecSuccess
        })
        XCTAssertNoThrow(try keychain.saveP12Password("my-passphrase", certificateSerialNumber: "some-serial"))
    }

    func testSaveP12Passphrase_Fail() {
        let keychain = Keychain(secItemAdd: { _, _ in errSecNoSuchAttr })
        XCTAssertThrowsError(try keychain.saveP12Password("my-passphrase", certificateSerialNumber: "some-serial")) { error in
            XCTAssertEqual(error as! KeychainError, .failedAddingPassword)
        }
    }

    func testSaveP12Passphrase_Update() {
        let updateExpectation = expectation(description: "Update expectation")
        let keychain = Keychain(
            secItemAdd: { _, _ in errSecDuplicateItem },
            secItemUpdate: { query, attributesToUpdate in
                let service = (query as! [String: Any])[kSecAttrService as String] as! String
                XCTAssertEqual(service, "AppDab certificate some-serial")
                let passphraseData = (attributesToUpdate as! [String: Any])[kSecValueData as String] as! Data
                XCTAssertEqual(String(data: passphraseData, encoding: .utf8), "my-passphrase")
                updateExpectation.fulfill()
                return errSecSuccess
            })
        XCTAssertNoThrow(try keychain.saveP12Password("my-passphrase", certificateSerialNumber: "some-serial"))
        wait(for: [updateExpectation], timeout: 5)
    }

    func testSaveP12Passphrase_UpdateFail() {
        let updateExpectation = expectation(description: "Update expectation")
        let keychain = Keychain(
            secItemAdd: { _, _ in errSecDuplicateItem },
            secItemUpdate: { _, _ in
                updateExpectation.fulfill()
                return errSecNoSuchAttr
            })
        XCTAssertThrowsError(try keychain.saveP12Password("my-passphrase", certificateSerialNumber: "some-serial")) { error in
            XCTAssertEqual(error as! KeychainError, .failedAddingPassword)
        }
        wait(for: [updateExpectation], timeout: 5)
    }

    func testImportPCKS12() {
        let p12Path = "some/path/to/key.p12"
        let passphrase = "some passphrase"
        let mockData = "something".data(using: .utf8)!
        let importExpectation = expectation(description: "Import expectation")
        let dataLoaderExpectation = expectation(description: "Data loader expectation")
        let keychain = Keychain(secPKCS12Import: { data, options, _ in
            XCTAssertEqual(data as Data, mockData)
            let usedPassphrase = (options as! [String: Any])[kSecImportExportPassphrase as String] as! String
            XCTAssertEqual(usedPassphrase, passphrase)
            importExpectation.fulfill()
            return errSecSuccess
        }, dataLoader: { url, _ in
            XCTAssertEqual(url, URL(fileURLWithPath: p12Path))
            dataLoaderExpectation.fulfill()
            return mockData
        })
        XCTAssertNoThrow(try keychain.importPCKS12(atPath: p12Path, passphrase: passphrase))
        wait(for: [importExpectation, dataLoaderExpectation], timeout: 5)
    }

    func testImportPCKS12_AuthFailed() {
        let importExpectation = expectation(description: "Import expectation")
        let dataLoaderExpectation = expectation(description: "Data loader expectation")
        let keychain = Keychain(secPKCS12Import: { _, _, _ in
            importExpectation.fulfill()
            return errSecAuthFailed
        }, dataLoader: { _, _ in
            dataLoaderExpectation.fulfill()
            return Data()
        })
        XCTAssertThrowsError(try keychain.importPCKS12(atPath: "some/path", passphrase: "wrong")) { error in
            XCTAssertEqual(error as! KeychainError, .wrongPassphraseForP12)
        }
        wait(for: [importExpectation, dataLoaderExpectation], timeout: 5)
    }

    func testImportPCKS12_VerifyFailure() {
        let importExpectation = expectation(description: "Import expectation")
        let dataLoaderExpectation = expectation(description: "Data loader expectation")
        let keychain = Keychain(secPKCS12Import: { _, _, _ in
            importExpectation.fulfill()
            return errSecPkcs12VerifyFailure
        }, dataLoader: { _, _ in
            dataLoaderExpectation.fulfill()
            return Data()
        })
        XCTAssertThrowsError(try keychain.importPCKS12(atPath: "some/path", passphrase: "wrong")) { error in
            XCTAssertEqual(error as! KeychainError, .wrongPassphraseForP12)
        }
        wait(for: [importExpectation, dataLoaderExpectation], timeout: 5)
    }

    func testImportPCKS12_UnknownStatus() {
        let importExpectation = expectation(description: "Import expectation")
        let dataLoaderExpectation = expectation(description: "Data loader expectation")
        let keychain = Keychain(secPKCS12Import: { _, _, _ in
            importExpectation.fulfill()
            return errSecNoSuchAttr
        }, dataLoader: { _, _ in
            dataLoaderExpectation.fulfill()
            return Data()
        })
        XCTAssertThrowsError(try keychain.importPCKS12(atPath: "some/path", passphrase: "wrong")) { error in
            XCTAssertEqual(error as! KeychainError, .errorImportingP12)
        }
        wait(for: [importExpectation, dataLoaderExpectation], timeout: 5)
    }

    func testKeychainErrorDescription() {
        XCTAssertEqual(KeychainError.noPasswordFound.description, "No password found in Keychain")
        XCTAssertEqual(KeychainError.failedAddingPassword.description, "Could not add password to Keychain")
        XCTAssertEqual(KeychainError.wrongPassphraseForP12.description, "Wrong passphrase for encrypted certificate and private key")
        XCTAssertEqual(KeychainError.errorImportingP12.description, "Could not import certificate and private key")
        XCTAssertEqual(KeychainError.unknown(status: errSecNoSuchAttr).description, "Unknown error occurred when interacting with Keychain (OSStatus: \(errSecNoSuchAttr))")
    }
}
