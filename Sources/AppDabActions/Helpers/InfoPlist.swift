import Foundation

internal protocol InfoPlistProtocol {
    func findInfoPlist() throws -> String
    func loadInfoPlist(at path: String) throws -> NSMutableDictionary
    func saveInfoPlist(_ infoPlist: NSDictionary, at path: String) throws
}

internal struct InfoPlist: InfoPlistProtocol {
    internal var dataLoader = Data.init(contentsOf:options:)
    internal var dataSaver = { (data: Data, path: String) throws in
        try data.write(to: URL(fileURLWithPath: path))
    }

    internal func findInfoPlist() throws -> String {
        ActionsEnvironment.logger.info("🔍 Looking up Info.plist file...")
        var projectFolder = try ActionsEnvironment.xcodebuild.findXcodeProject(at: ".")
        ActionsEnvironment.logger.trace("Found project folder '\(projectFolder)'")
        projectFolder.removeLast(10)
        ActionsEnvironment.logger.trace("Looking up Info.plist file in '\(projectFolder)'")
        let allItemsInProjectFolder = try ActionsEnvironment.fileManager.contentsOfDirectory(atPath: "./\(projectFolder)")
        guard let infoPlistFileName = allItemsInProjectFolder.first(where: { $0.hasSuffix("Info.plist") }) else {
            throw InfoPlistError.infoPlistNotFound
        }
        let path = "./\(projectFolder)/\(infoPlistFileName)"
        ActionsEnvironment.logger.info("👍 Found Info.plist file at path: \(path)")
        return path
    }

    internal func loadInfoPlist(at path: String) throws -> NSMutableDictionary {
        ActionsEnvironment.logger.trace("Loading Info.plist file at path: \(path)")
        let data = try dataLoader(URL(fileURLWithPath: path), [])
        return try PropertyListSerialization.propertyList(from: data, options: .mutableContainersAndLeaves, format: nil) as! NSMutableDictionary
    }

    internal func saveInfoPlist(_ infoPlist: NSDictionary, at path: String) throws {
        ActionsEnvironment.logger.trace("Saving data to path: \(path)")
        let data = try PropertyListSerialization.data(fromPropertyList: infoPlist, format: .xml, options: 0)
        try dataSaver(data, path)
    }
}

public enum InfoPlistError: ActionError, Equatable {
    case infoPlistNotFound
    case wrongTypeForKey(key: String, path: String)

    public var description: String {
        switch self {
        case .infoPlistNotFound:
            return "The Info.plist could not be found"
        case .wrongTypeForKey(let key, let path):
            return "No value found for key '\(key)' in Info.plist at path: \(path)"
        }
    }
}
