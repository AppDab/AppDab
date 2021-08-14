import Foundation

internal protocol ShellProtocol {
    @discardableResult
    func run(_ command: String, at path: String, outputCallback: ((String) -> Void)?) throws -> String
}

internal extension ShellProtocol {
    @discardableResult
    func run(_ command: String, at path: String = ".", outputCallback: ((String) -> Void)? = nil) throws -> String {
        try run(command, at: path, outputCallback: outputCallback)
    }
}

#if os(macOS)
internal struct Shell: ShellProtocol {
    internal func run(_ command: String, at path: String, outputCallback: ((String) -> Void)?) throws -> String {
        let augmentedCommand: String
        if path == "." {
            augmentedCommand = command
        } else {
            augmentedCommand = "cd \(path) && \(command)"
        }
        let temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        let temporaryFilename = ProcessInfo().globallyUniqueString
        let temporaryFileURL = temporaryDirectoryURL.appendingPathComponent(temporaryFilename).appendingPathExtension("log")
        FileManager.default.createFile(atPath: temporaryFileURL.path, contents: Data(), attributes: nil)
        let logFileHandle = try FileHandle(forWritingTo: temporaryFileURL)
        ActionsEnvironment.logger.trace("⚡️ \(augmentedCommand)")
        ActionsEnvironment.logger.trace("Saving command output to: \(temporaryFileURL)")

        var outputData = Data()
        var errorData = Data()
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        var textBuffer: String?
        outputPipe.fileHandleForReading.readabilityHandler = {
            let data = $0.availableData
            logFileHandle.write(data)
            outputData.append(data)
            if let text = String(data: data, encoding: .utf8) {
                guard text.hasSuffix("\n") else {
                    textBuffer = text
                    return
                }
                let linesText = (textBuffer ?? "") + text
                textBuffer = nil
                let lines = linesText
                    .split(separator: "\n")
                    .map(String.init)
//            if linesText.hasPrefix("\n") {
//                lines.insert("", at: 0)
//            }
//            if linesText.hasSuffix("\n") {
//                lines.append("")
//            }
                lines.forEach(outputCallback ?? { _ in })
            }
        }
        errorPipe.fileHandleForReading.readabilityHandler = {
            let data = $0.availableData
            logFileHandle.write(data)
            errorData.append(data)
        }

        let process = Process()
        process.launchPath = "/bin/zsh"
        process.arguments = ["-c", augmentedCommand]
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        process.launch()
        process.waitUntilExit()
        guard process.terminationStatus == 0 else {
            throw ShellError(terminationStatus: process.terminationStatus,
                             logFileUrl: temporaryFileURL,
                             outputData: outputData,
                             errorData: errorData)
        }
        return String(data: outputData, encoding: .utf8) ?? ""
    }
}
#endif

internal struct ShellError: Error {
    let terminationStatus: Int32
    let logFileUrl: URL
    let outputData: Data
    let errorData: Data
    var message: String {
        (String(data: errorData, encoding: .utf8) ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
