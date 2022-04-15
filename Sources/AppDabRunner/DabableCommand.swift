import AppDabActions
import ArgumentParser
import Foundation

/// A async command which has settings for AppDab actions and a function which calls actions.
public protocol DabableCommand: AsyncParsableCommand {
    /// The settings to apply to the ``ActionsEnvironment`` before running the actions.
    static var settings: Settings { get }
    /// The function which calls actions.
    func runActions() async throws
}

public extension DabableCommand {
    func run() async throws {
        if ProcessInfo.processInfo.runFromXcode {
            FileManager.default.changeCurrentDirectoryPath(ProcessInfo.processInfo.environment["PWD"]!)
        } else {
            FileManager.default.changeCurrentDirectoryPath("..")
        }
        ActionsEnvironment.settings = Self.settings
        do {
            try await runActions()
        } catch (let error) {
            let runActionsError = mapErrorToAppDabError(error: error)
            logAppDabError(runActionsError)
            throw error
        }
    }
}
