import AppDabActions
import Bagbutik_Models
import XCTest

//final class EnsureCertificateTests: ActionsTestCase {
//    func testEnsureCertificate() async {
//        let fetchResponse = CertificatesResponse(
//            data: [],
//            links: .init(self: ""))
//        mockBagbutikService.setResponse(fetchResponse, for: .init(path: "/v1/certificates", method: .get))
//        try! await ensureCertificate()
//        XCTAssertEqual(mockLogHandler.logs,[
//            Log(level: .info, message: "⏬ Fetching list of available certificates..."),
//            Log(level: .info, message: "🤷🏼 No certificates found online"),
//            Log(level: .error, message: "🚫 In read-only mode, so no new certificate is created"),
//        ])
//    }
//}
