@testable import AppDabActions
import XCTest

final class KeychainTests: XCTestCase {
    // MARK: List generic passwords

    func testListGenericPasswords() throws {
        let genericPassword = GenericPassword(account: "P9M252746H", label: "Apple", generic: Data("82067982-6b3b-4a48-be4f-5b10b373c5f2".utf8), value: Data("""
        -----BEGIN PRIVATE KEY-----
        MIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQgevZzL1gdAFr88hb2
        OF/2NxApJCzGCEDdfSp6VQO30hyhRANCAAQRWz+jn65BtOMvdyHKcvjBeBSDZH2r
        1RTwjmYSi9R/zpBnuQ4EiMnCqfMPWiZqB4QdbAd0E7oH50VpuZ1P087G
        -----END PRIVATE KEY-----
        """.utf8))
        let service = "AppDab"
        let keychain = Keychain(secItemCopyMatching: { _, result in
            result?.pointee = [[
                kSecAttrLabel: genericPassword.label,
                kSecAttrAccount: genericPassword.account,
                kSecAttrGeneric: genericPassword.generic,
                kSecValueData: genericPassword.value
            ]] as CFTypeRef
            return errSecSuccess
        })
        XCTAssertEqual(try keychain.listGenericPasswords(forService: service), [genericPassword])
    }

    func testListGenericPasswords_NoPasswordFound() {
        let keychain = Keychain(secItemCopyMatching: { _, _ in errSecItemNotFound })
        XCTAssertEqual(try keychain.listGenericPasswords(forService: "AppDab"), [])
    }

    func testListGenericPasswords_Unknown() {
        let keychain = Keychain(secItemCopyMatching: { _, _ in errSecParam })
        XCTAssertThrowsError(try keychain.listGenericPasswords(forService: "AppDab")) { error in
            XCTAssertEqual(error as! KeychainError, .errorReadingFromKeychain(errSecParam))
        }
    }

    func testListGenericPasswords_InvalidPassword() throws {
        let keychain = Keychain(secItemCopyMatching: { query, result in
            let query = query as NSDictionary
            if query[kSecReturnRef] != nil {
                result?.pointee = ["item"] as CFTypeRef
            } else {
                result?.pointee = [:] as CFTypeRef
            }
            return errSecSuccess
        })
        XCTAssertThrowsError(try keychain.listGenericPasswords(forService: "AppDab")) { error in
            XCTAssertEqual(error as! KeychainError, .errorReadingFromKeychain(errSecSuccess))
        }
    }

    // MARK: Update generic password

    func testAddGenericPassword() {
        let keychain = Keychain(secItemAdd: { _, _ in errSecSuccess })
        let genericPassword = GenericPassword(account: "", label: "", generic: Data(), value: Data())
        XCTAssertNoThrow(try keychain.addGenericPassword(forService: "AppDab", password: genericPassword))
    }

    func testAddGenericPassword_Duplicate() {
        let keychain = Keychain(secItemAdd: { _, _ in errSecDuplicateItem })
        let genericPassword = GenericPassword(account: "", label: "", generic: Data(), value: Data())
        XCTAssertThrowsError(try keychain.addGenericPassword(forService: "AppDab", password: genericPassword)) { error in
            XCTAssertEqual(error as! KeychainError, .duplicatePassword)
        }
    }

    func testAddGenericPassword_Unknown() {
        let status = errSecParam
        let keychain = Keychain(secItemAdd: { _, _ in status })
        let genericPassword = GenericPassword(account: "", label: "", generic: Data(), value: Data())
        XCTAssertThrowsError(try keychain.addGenericPassword(forService: "AppDab", password: genericPassword)) { error in
            XCTAssertEqual(error as! KeychainError, .failedAddingPassword(status))
        }
    }

    // MARK: Update generic password

    func testUpdateGenericPassword() {
        let keychain = Keychain(secItemUpdate: { _, _ in errSecSuccess })
        let genericPassword = GenericPassword(account: "", label: "", generic: Data(), value: Data())
        XCTAssertNoThrow(try keychain.updateGenericPassword(forService: "AppDab", password: genericPassword))
    }

    func testUpdateGenericPassword_Unknown() {
        let keychain = Keychain(secItemUpdate: { _, _ in errSecParam })
        let genericPassword = GenericPassword(account: "", label: "", generic: Data(), value: Data())
        XCTAssertThrowsError(try keychain.updateGenericPassword(forService: "AppDab", password: genericPassword)) { error in
            XCTAssertEqual(error as! KeychainError, .failedUpdatingPassword)
        }
    }

    // MARK: Delete generic password

    func testDeleteGenericPassword() {
        let keychain = Keychain(secItemDelete: { _ in errSecSuccess })
        let genericPassword = GenericPassword(account: "", label: "", generic: Data(), value: Data())
        XCTAssertNoThrow(try keychain.deleteGenericPassword(forService: "AppDab", password: genericPassword))
    }

    func testDeleteGenericPassword_Unknown() {
        let keychain = Keychain(secItemDelete: { _ in errSecParam })
        let genericPassword = GenericPassword(account: "", label: "", generic: Data(), value: Data())
        XCTAssertThrowsError(try keychain.deleteGenericPassword(forService: "AppDab", password: genericPassword)) { error in
            XCTAssertEqual(error as! KeychainError, .failedDeletingPassword)
        }
    }

    // MARK: Read P12 passphrase

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

    // MARK: Save P12 passphrase

    func testSaveP12Passphrase() {
        let keychain = Keychain(secItemAdd: { query, _ in
            let service = (query as! [String: Any])[kSecAttrService as String] as! String
            XCTAssertEqual(service, "AppDab certificate some-serial")
            return errSecSuccess
        })
        XCTAssertNoThrow(try keychain.saveP12Password("my-passphrase", certificateSerialNumber: "some-serial"))
    }

    func testSaveP12Passphrase_Fail() {
        let status = errSecNoSuchAttr
        let keychain = Keychain(secItemAdd: { _, _ in status })
        XCTAssertThrowsError(try keychain.saveP12Password("my-passphrase", certificateSerialNumber: "some-serial")) { error in
            XCTAssertEqual(error as! KeychainError, .failedAddingPassword(status))
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
        let status = errSecNoSuchAttr
        let keychain = Keychain(
            secItemAdd: { _, _ in errSecDuplicateItem },
            secItemUpdate: { _, _ in
                updateExpectation.fulfill()
                return status
            })
        XCTAssertThrowsError(try keychain.saveP12Password("my-passphrase", certificateSerialNumber: "some-serial")) { error in
            XCTAssertEqual(error as! KeychainError, .failedAddingPassword(status))
        }
        wait(for: [updateExpectation], timeout: 5)
    }

    // MARK: Import PCKS#12

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

    // MARK: Keychain error

    func testKeychainErrorDescription() {
        XCTAssertEqual(KeychainError.noPasswordFound.description, "No password found in Keychain")
        XCTAssertEqual(KeychainError.failedAddingPassword(errSecDuplicateItem).description, "Could not add password to Keychain")
        XCTAssertEqual(KeychainError.wrongPassphraseForP12.description, "Wrong passphrase for encrypted certificate and private key")
        XCTAssertEqual(KeychainError.errorImportingP12.description, "Could not import certificate and private key")
        XCTAssertEqual(KeychainError.unknown(status: errSecNoSuchAttr).description, "Unknown error occurred when interacting with Keychain (OSStatus: \(errSecNoSuchAttr))")
    }
}

extension GenericPassword: @retroactive Equatable {
    public static func == (lhs: GenericPassword, rhs: GenericPassword) -> Bool {
        lhs.account == rhs.account
            && lhs.label == rhs.label
            && lhs.generic == rhs.generic
            && lhs.value == rhs.value
    }
}
