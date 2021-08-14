import Bagbutik
import Dispatch
import Foundation

extension BagbutikService: PatchedBagbutikServiceProtocol {
    public func requestSynchronously<T: Decodable>(_ request: Request<T, ErrorResponse>) -> Result<T, Error>
    {
        var result: Result<T, Error>?
        let semaphore = DispatchSemaphore(value: 0)
        self.request(request, completionHandler: { innerResult in
            switch innerResult {
            case .success(let response):
                result = .success(response)
            case .failure(let error):
                result = .failure(error)
            }
            semaphore.signal()
        })
        semaphore.wait()
        return result!
    }
}
