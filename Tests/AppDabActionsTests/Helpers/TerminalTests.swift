@testable import AppDabActions
import XCTest

final class TerminalTests: ActionsTestCase {
    func testSelectOption_NumberOnly() throws {
        let getInputExpectation = expectation(description: "Get input expectation")
        let text = "Multiple items found. Which should be used?"
        let items = ["Some item", "Some other item", "Different item"]
        let terminal = Terminal(getInput: { secret in
            XCTAssertFalse(secret)
            getInputExpectation.fulfill()
            return "2"
        })
        let option = try terminal.selectOption(text: text, items: items)
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .warning, message: """
            \(text)
            Select an option by entering the number:
            1. \(items[0])
            2. \(items[1])
            3. \(items[2])
            """),
        ])
        XCTAssertEqual(option.index, 1)
        XCTAssertEqual(option.item, items[1])
        wait(for: [getInputExpectation], timeout: 5)
    }

    func testSelectOption_NumberOnly_Invalid() throws {
        let getInputExpectation = expectation(description: "Get input expectation")
        let text = "Multiple items found. Which should be used?"
        let items = ["Some item", "Some other item", "Different item"]
        let terminal = Terminal(getInput: { secret in
            XCTAssertFalse(secret)
            getInputExpectation.fulfill()
            return "Some item"
        })
        XCTAssertThrowsError(try terminal.selectOption(text: text, items: items)) { error in
            XCTAssertEqual(error as! TerminalError, .invalidOption)
        }
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .warning, message: """
            \(text)
            Select an option by entering the number:
            1. \(items[0])
            2. \(items[1])
            3. \(items[2])
            """),
        ])
        wait(for: [getInputExpectation], timeout: 5)
    }

    func testSelectOption_TextSelection() throws {
        let getInputExpectation = expectation(description: "Get input expectation")
        let text = "Multiple items found. Which should be used?"
        let items = ["Some item", "Some other item", "Different item"]
        let terminal = Terminal(getInput: { secret in
            XCTAssertFalse(secret)
            getInputExpectation.fulfill()
            return "Different item"
        })
        let option = try terminal.selectOption(text: text, items: items, allowTextSelection: true)
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .warning, message: """
            \(text)
            Select an option by entering the number or value:
            1. \(items[0])
            2. \(items[1])
            3. \(items[2])
            """),
        ])
        XCTAssertEqual(option.index, 2)
        XCTAssertEqual(option.item, items[2])
        wait(for: [getInputExpectation], timeout: 5)
    }

    func testSelectOption_TextSelection_Invalid() throws {
        let getInputExpectation = expectation(description: "Get input expectation")
        let text = "Multiple items found. Which should be used?"
        let items = ["Some item", "Some other item", "Different item"]
        let terminal = Terminal(getInput: { secret in
            XCTAssertFalse(secret)
            getInputExpectation.fulfill()
            return "Invalid item"
        })
        XCTAssertThrowsError(try terminal.selectOption(text: text, items: items, allowTextSelection: true)) { error in
            XCTAssertEqual(error as! TerminalError, .invalidOption)
        }
        XCTAssertEqual(mockLogHandler.logs, [
            Log(level: .warning, message: """
            \(text)
            Select an option by entering the number or value:
            1. \(items[0])
            2. \(items[1])
            3. \(items[2])
            """),
        ])
        wait(for: [getInputExpectation], timeout: 5)
    }

    func testGetBoolInput_Yes() {
        let getSingleCharacterInputExpectation = expectation(description: "Get single character input expectation")
        let question = "Do you want to continue?"
        let terminal = Terminal(getSingleCharacterInput: {
            getSingleCharacterInputExpectation.fulfill()
            return "Y"
        })
        XCTAssertTrue(terminal.getBoolInput(question: question))
        XCTAssertEqual(mockLogHandler.logs, [Log(level: .info, message: "❓ \(question) [Y/n]")])
        wait(for: [getSingleCharacterInputExpectation], timeout: 5)
    }
    
    func testGetBoolInput_No() {
        let getSingleCharacterInputExpectation = expectation(description: "Get single character input expectation")
        let question = "Do you want to continue?"
        let terminal = Terminal(getSingleCharacterInput: {
            getSingleCharacterInputExpectation.fulfill()
            return "n"
        })
        XCTAssertFalse(terminal.getBoolInput(question: question))
        XCTAssertEqual(mockLogHandler.logs, [Log(level: .info, message: "❓ \(question) [Y/n]")])
        wait(for: [getSingleCharacterInputExpectation], timeout: 5)
    }
    
    func testGetBoolInput_Random() {
        let getSingleCharacterInputExpectation = expectation(description: "Get single character input expectation")
        let question = "Do you want to continue?"
        let terminal = Terminal(getSingleCharacterInput: {
            getSingleCharacterInputExpectation.fulfill()
            return "+"
        })
        XCTAssertFalse(terminal.getBoolInput(question: question))
        XCTAssertEqual(mockLogHandler.logs, [Log(level: .info, message: "❓ \(question) [Y/n]")])
        wait(for: [getSingleCharacterInputExpectation], timeout: 5)
    }
    
    func testTerminalErrorDescription() {
        XCTAssertEqual(TerminalError.invalidOption.description, "The chosen option is not valid")
    }
}
