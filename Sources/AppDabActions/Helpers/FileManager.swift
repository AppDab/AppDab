import Foundation

internal protocol FileManagerProtocol {
    var temporaryDirectory: URL { get }
    func contentsOfDirectory(atPath path: String) throws -> [String]
    func createDirectory(atPath path: String, withIntermediateDirectories createIntermediates: Bool, attributes: [FileAttributeKey: Any]?) throws
    func createFile(atPath path: String, contents data: Data?, attributes attr: [FileAttributeKey: Any]?) -> Bool
    func removeItem(atPath: String) throws
}

extension FileManager: FileManagerProtocol {}
