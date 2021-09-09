import AppDabActions
import Bagbutik
import Foundation
import XCTest

final class RevokeCertificateTests: ActionsTestCase {
    func testRevokeCertificate_WithSerialNumber() async {
        let fetchResponse = CertificatesResponse(
            data: [.init(id: "some-id", links: .init(self: ""), attributes: .init(expirationDate: mockDate, name: "Apple Distribution: Steve Jobs", serialNumber: "SOMESERIALNUMBER"))],
            links: .init(self: "")
        )
        let deleteResponse = EmptyResponse()
        mockBagbutikService.setResponse(fetchResponse, for: Endpoint(path: "/v1/certificates", method: .get))
        mockBagbutikService.setResponse(deleteResponse, for: Endpoint(path: "/v1/certificates/some-id", method: .delete))
        try! await revokeCertificate(withSerialNumber: "SOMESERIALNUMBER")
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "🚀 Fetching certificate by serial number 'SOMESERIALNUMBER'..."),
            Log(level: .info, message: "👍 Found certificate 'SOMESERIALNUMBER' (some-id)"),
            Log(level: .info, message: "🚀 Revoking certificate 'some-id'..."),
            Log(level: .info, message: "👍 Certificate revoked"),
        ])
    }

    func testRevokeCertificate_WithSerialNumber_NotFound() async {
        let fetchResponse = CertificatesResponse(data: [], links: .init(self: ""))
        mockBagbutikService.setResponse(fetchResponse, for: Endpoint(path: "/v1/certificates", method: .get))
        await XCTAssertAsyncThrowsError(try await revokeCertificate(withSerialNumber: "SOMESERIALNUMBER")) { error in
            XCTAssertEqual(error as! CertificateError, .certificateWithSerialNumberNotFound("SOMESERIALNUMBER"))
        }
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "🚀 Fetching certificate by serial number 'SOMESERIALNUMBER'..."),
        ])
    }

    func testRevokeCertificate_WithName() async {
        let fetchResponse = CertificatesResponse(
            data: [.init(id: "some-id", links: .init(self: ""), attributes: .init(expirationDate: mockDate, name: "Apple Distribution: Steve Jobs", serialNumber: "SOMESERIALNUMBER"))],
            links: .init(self: "")
        )
        let deleteResponse = EmptyResponse()
        mockBagbutikService.setResponse(fetchResponse, for: Endpoint(path: "/v1/certificates", method: .get))
        mockBagbutikService.setResponse(deleteResponse, for: Endpoint(path: "/v1/certificates/some-id", method: .delete))
        try! await revokeCertificate(named: "Apple Distribution: Steve Jobs")
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "🚀 Fetching certificate by name 'Apple Distribution: Steve Jobs'..."),
            Log(level: .info, message: "👍 Found certificate named 'Apple Distribution: Steve Jobs' (some-id)"),
            Log(level: .info, message: "🚀 Revoking certificate 'some-id'..."),
            Log(level: .info, message: "👍 Certificate revoked"),
        ])
    }

    func testDeleteBundleId_WithName_NotFound() async {
        let fetchResponse = CertificatesResponse(data: [], links: .init(self: ""))
        mockBagbutikService.setResponse(fetchResponse, for: Endpoint(path: "/v1/certificates", method: .get))
        await XCTAssertAsyncThrowsError(try await revokeCertificate(named: "SOMESERIALNUMBER")) { error in
            XCTAssertEqual(error as! CertificateError, .certificateWithNameNotFound("SOMESERIALNUMBER"))
        }
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "🚀 Fetching certificate by name 'SOMESERIALNUMBER'..."),
        ])
    }
}
