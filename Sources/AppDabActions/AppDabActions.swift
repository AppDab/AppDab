import Bagbutik
import Foundation

/**
 Runs the actions specified in the closure. Any thrown errors will be catched and logged.
 
 - Parameter actions: A closure with some code calling actions
 */
public func runActions(_ actions: () throws -> Void) {
    do {
        try actions()
    } catch {
        if let error = error as? BagbutikService.ServiceError, let description = error.description {
            ActionsEnvironment.logger.error("💥 \(description)")
        } else if let error = error as? ActionError {
            ActionsEnvironment.logger.error("💥 \(error.description)")
        } else if let error = error as? ShellError {
            ActionsEnvironment.logger.error("💥 \(error.message)")
            ActionsEnvironment.logger.error("The full log is here: \(error.logFileUrl)")
        } else {
            ActionsEnvironment.logger.error("💥 Unhandled error. Please report it as an issue on Github 🥰")
            ActionsEnvironment.logger.error("Error description: \(error.localizedDescription)")
            ActionsEnvironment.logger.error("Stacktrace:\n\(Thread.callStackSymbols.joined(separator: "\n"))")
        }
    }
}

/// Error originating from an action.
public protocol ActionError: Error {
    /// The description of the error
    var description: String { get }
}
