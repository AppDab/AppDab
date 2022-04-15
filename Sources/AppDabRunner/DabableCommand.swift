import AppDabActions
import ArgumentParser
import Foundation

public protocol DabableCommand: AsyncParsableCommand {
    static var settings: Settings { get }
    static var actions: () async throws -> Void { get }
}

public extension DabableCommand {
    func run() async throws {
        if ProcessInfo.processInfo.runFromXcode {
            FileManager.default.changeCurrentDirectoryPath(ProcessInfo.processInfo.environment["PWD"]!)
        } else {
            FileManager.default.changeCurrentDirectoryPath("..")
        }
        ActionsEnvironment.settings = Self.settings
        await runActions(Self.actions)
    }
}
