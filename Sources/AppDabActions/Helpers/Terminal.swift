import Foundation

internal protocol TerminalProtocol {
    func selectOption(text: String, items: [String], allowTextSelection: Bool) throws -> (index: Int, item: String)
    func getInput(secret: Bool) -> String
    func getBoolInput(question: String) -> Bool
}

internal extension TerminalProtocol {
    func selectOption(text: String, items: [String], allowTextSelection: Bool = false) throws -> (index: Int, item: String) {
        try selectOption(text: text, items: items, allowTextSelection: allowTextSelection)
    }
}

internal struct Terminal: TerminalProtocol {
    internal var getInput = { (secret: Bool) -> String in
        let input: String
        if secret {
            let keyboard = FileHandle.standardInput
            let inputData = keyboard.availableData
            input = String(data: inputData, encoding: String.Encoding.utf8) ?? ""
        } else {
            input = String(cString: getpass("")!)
        }
        return input.trimmingCharacters(in: CharacterSet.newlines)
    }
    
    internal var getSingleCharacterInput = { () -> String in
        // Inspired by: https://stackoverflow.com/a/59795707/687540
        let handle = FileHandle.standardInput
        let term = handle.enableRawMode()
        defer { handle.disableRawMode(originalTerm: term) }
        
        var byte: UInt8 = 0
        read(handle.fileDescriptor, &byte, 1)
        return String(bytes: [byte], encoding: .utf8) ?? ""
    }

    internal func selectOption(text: String, items: [String], allowTextSelection: Bool = false) throws -> (index: Int, item: String) {
        ActionsEnvironment.logger.warning("""
        \(text)
        Select an option by entering the number\(allowTextSelection ? " or value" : ""):
        \(createNumberedList(from: items).joined(separator: "\n"))
        """)
        let input = getInput(secret: false)
        if let number = Int(input), number > 0, number <= items.count {
            let index = number - 1
            return (index: index, item: items[index])
        } else if allowTextSelection, let index = items.firstIndex(of: input) {
            return (index: index, item: input)
        }
        throw TerminalError.invalidOption
    }

    internal func getInput(secret: Bool) -> String {
        return getInput(secret)
    }

    internal func getBoolInput(question: String) -> Bool {
        ActionsEnvironment.logger.info("❓ \(question) [Y/n]")
        let input = getSingleCharacterInput()
        print() // We do this to keep the entered character in the output
        return input.lowercased() == "y"
    }

    private func createNumberedList(from items: [String]) -> [String] {
        var numberedItems = [String]()
        for (index, item) in items.enumerated() {
            numberedItems.append("\(index + 1). \(item)")
        }
        return numberedItems
    }
}

internal enum TerminalError: ActionError {
    case invalidOption

    internal var description: String {
        switch self {
        case .invalidOption:
            return "The chosen option is not valid"
        }
    }
}

private extension FileHandle {
    func enableRawMode() -> termios {
        var original = termios()
        tcgetattr(fileDescriptor, &original)

        var raw = original
        raw.c_lflag &= ~UInt(ECHO | ICANON)
        tcsetattr(fileDescriptor, TCSADRAIN, &raw)

        return original
    }

    func disableRawMode(originalTerm: termios) {
        var term = originalTerm
        tcsetattr(fileDescriptor, TCSADRAIN, &term)
    }
}
