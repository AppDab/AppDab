import AppDabActions
import Bagbutik
import Foundation
import XCTest

final class ListCertificatesTests: ActionsTestCase {
    func testListCertificates() async {
        let expirationDateInFuture = Date.now.addingTimeInterval(10000)
        let expirationDateInFutureString = expirationDateInFuture.formatted(date: .abbreviated, time: .shortened)
        let expirationDateInPastString = mockDate.formatted(date: .abbreviated, time: .shortened)
        let response = CertificatesResponse(
            data: [.init(id: "certificate-1", links: .init(self: ""), attributes: .init(expirationDate: expirationDateInFuture, name: "Apple Distribution: Steve Jobs", serialNumber: "SOMESERIALNUMBER")),
                   .init(id: "certificate-2", links: .init(self: ""), attributes: .init(expirationDate: mockDate, name: "Apple Developer: Scott Forstall", serialNumber: "ANOTHERSERIALNUMBER"))],
            links: .init(self: "")
        )
        mockBagbutikService.setResponse(response, for: Endpoint(path: "/v1/certificates", method: .get))
        let certificates = try! await listCertificates()
        XCTAssertEqual(certificates, response.data)
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .info, message: "🚀 Fetching list of certificates..."),
            Log(level: .info, message: "👍 Certificates fetched"),
            Log(level: .info, message: " ◦ 🟢 Apple Distribution: Steve Jobs (SOMESERIALNUMBER) expires \(expirationDateInFutureString)"),
            Log(level: .info, message: " ◦ 🔴 Apple Developer: Scott Forstall (ANOTHERSERIALNUMBER) expired \(expirationDateInPastString)"),
        ])
    }
}

extension Certificate: Equatable {
    public static func == (lhs: Certificate, rhs: Certificate) -> Bool {
        lhs.id == rhs.id
    }
}
