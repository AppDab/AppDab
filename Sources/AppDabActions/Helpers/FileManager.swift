import Foundation

internal protocol FileManagerProtocol {
    func contentsOfDirectory(atPath path: String) throws -> [String]
}

extension FileManager: FileManagerProtocol {}
