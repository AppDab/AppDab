import Foundation

internal protocol AppDabURLSessionProtocol {
    func upload(for request: URLRequest, from bodyData: Data, delegate: URLSessionTaskDelegate?) async throws -> (Data, URLResponse)
}

extension URLSession: AppDabURLSessionProtocol {}
