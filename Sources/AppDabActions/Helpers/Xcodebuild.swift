import Foundation

#if os(macOS)
internal protocol XcodebuildProtocol {
    func findXcodeProject(at path: String) throws -> String
    func findSchemeName(at path: String) throws -> String
}

internal struct Xcodebuild: XcodebuildProtocol {
    internal func findXcodeProject(at path: String) throws -> String {
        let allItemsInCurrentFolder = try ActionsEnvironment.fileManager.contentsOfDirectory(atPath: path)
        guard let projectFolder = allItemsInCurrentFolder.first(where: { $0.hasSuffix(".xcodeproj") }) else {
            throw XcodebuildError.xcodeProjNotFound
        }
        return projectFolder
    }

    internal func findSchemeName(at path: String) throws -> String {
        let projectName = try findXcodeProject(at: path)
        let potentialSchemeName = String(projectName[..<projectName.index(projectName.endIndex, offsetBy: -10)])
        let output = try ActionsEnvironment.shell.run("xcodebuild -list", at: path)
        guard let startOfSchemesIndex = output.range(of: "Schemes:")?.upperBound else {
            throw XcodebuildError.unkownSchemesListOutput(output)
        }
        let schemes = output
            .suffix(from: startOfSchemesIndex)
            .split(separator: "\n")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { $0 != "" }
        if schemes.contains(potentialSchemeName) {
            return potentialSchemeName
        }
        return try ActionsEnvironment.terminal.selectOption(text: "Scheme not defined, and no scheme matches the project name. Which scheme should be used?", items: schemes, allowTextSelection: true).item
    }
}

public enum XcodebuildError: ActionError, Equatable {
    case xcodeProjNotFound
    case unkownSchemesListOutput(String)
    case archivePathMissing
    case exportedArchiveNotFound
    case testResultNotFound

    public var description: String {
        switch self {
        case .xcodeProjNotFound:
            return "Xcode project could not be found"
        case .unkownSchemesListOutput(let output):
            return "Unexpected schemes list. Please report it as an issue on Github 🥰\nAttach the following output if possible and the version of Xcode used:\n\(output)"
        case .archivePathMissing:
            return "Archive path is not specified"
        case .exportedArchiveNotFound:
            return "Could not find exported archive"
        case .testResultNotFound:
            return "Could not find test results"
        }
    }
}
#endif
