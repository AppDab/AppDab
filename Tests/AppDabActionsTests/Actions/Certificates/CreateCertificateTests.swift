import AppDabActions
import Bagbutik_Models
import XCTest

final class CreateCertificateTests: ActionsTestCase {
    func testCreateCertificate() async {
        let response = CertificateResponse(
            data: .init(id: "some-id", links: .init(self: "")),
            links: .init(self: "")
        )
        mockBagbutikService.setResponse(response, for: Endpoint(path: "/v1/certificates", method: .post))
        let certificate = try! await createCertificate(type: .development)
        XCTAssertEqual(certificate, response.data)
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "🚀 Creating a 'Apple Development' certificate..."),
            Log(level: .info, message: "👍 Certificate created"),
        ])
    }
    
    func testCreateCertificate_UnableToCreatePrivateKey() async {
        skipTearDownCheck(for: .bagbutikService)
        let response = CertificateResponse(
            data: .init(id: "some-id", links: .init(self: "")),
            links: .init(self: "")
        )
        mockBagbutikService.setResponse(response, for: Endpoint(path: "/v1/certificates", method: .post))
        mockKeychain.createRandomKeyShouldSucceed = false
        await XCTAssertAsyncThrowsError(try await createCertificate(type: .development)) { error in
            XCTAssertEqual((error as NSError).domain, "SecKeyCreateRandomKey")
        }
    }
    
    func testCreateCertificate_UnableToCreatePublicKey() async {
        skipTearDownCheck(for: .bagbutikService)
        let response = CertificateResponse(
            data: .init(id: "some-id", links: .init(self: "")),
            links: .init(self: "")
        )
        mockBagbutikService.setResponse(response, for: Endpoint(path: "/v1/certificates", method: .post))
        mockKeychain.copyPublicKeyShouldSucceed = false
        await XCTAssertAsyncThrowsError(try await createCertificate(type: .development)) { error in
            XCTAssertEqual(error as! CreateCertificateError, .errorCreatingPublicKey)
        }
    }
    
    func testCreateCertificate_UnableToGetPublicKeyData() async {
        skipTearDownCheck(for: .bagbutikService)
        let response = CertificateResponse(
            data: .init(id: "some-id", links: .init(self: "")),
            links: .init(self: "")
        )
        mockBagbutikService.setResponse(response, for: Endpoint(path: "/v1/certificates", method: .post))
        mockKeychain.copyPublicKeyDataShouldSucceed = false
        await XCTAssertAsyncThrowsError(try await createCertificate(type: .development)) { error in
            XCTAssertEqual((error as NSError).domain, "SecKeyCopyExternalRepresentation")
        }
    }
    
    func testCreateCertificate_InvalidPublicKeyData() async {
        skipTearDownCheck(for: .bagbutikService)
        let response = CertificateResponse(
            data: .init(id: "some-id", links: .init(self: "")),
            links: .init(self: "")
        )
        mockBagbutikService.setResponse(response, for: Endpoint(path: "/v1/certificates", method: .post))
        let privateKey = try! mockKeychain.createPrivateKey(labeled: "AppDabTest")
        mockKeychain.publicKeyToReturn = SecKeyCopyPublicKey(privateKey)
        await XCTAssertAsyncThrowsError(try await createCertificate(type: .development)) { error in
            XCTAssertEqual(error as! CreateCertificateError, .errorCreatingSigningRequest)
        }
    }
}

