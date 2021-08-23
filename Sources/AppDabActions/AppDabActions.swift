import Bagbutik
import Foundation

/**
 Runs the actions specified in the closure. Any thrown errors will be catched and logged.

 - Parameter actions: A closure with some code calling actions
 */
public func runActions(_ actions: () throws -> Void) {
    do {
        try actions()
    } catch (let error) {
        let runActionsError = mapErrorToAppDabError(error: error)
        logAppDabError(runActionsError)
    }
}

public func mapErrorToAppDabError(error: Error) -> AppDabError {
    if let error = error as? BagbutikService.ServiceError, let description = error.description {
        return .simpleError(message: description)
    } else if let error = error as? ActionError {
        return .simpleError(message: error.description)
    } else if let error = error as? ShellError {
        return .loggedError(message: error.message, logFileUrl: error.logFileUrl)
    } else {
        let stackTrace = Thread.callStackSymbols.joined(separator: "\n")
        return .unhandledError(message: error.localizedDescription, stackTrace: stackTrace)
    }
}

public func logAppDabError(_ error: AppDabError) {
    switch error {
    case .simpleError(let message):
        ActionsEnvironment.logger.error("💥 \(message)")
    case .loggedError(let message, let logFileUrl):
        ActionsEnvironment.logger.error("💥 \(message)")
        ActionsEnvironment.logger.error("The full log is here: \(logFileUrl)")
    case .unhandledError(let message, let stackTrace):
        ActionsEnvironment.logger.error("💥 Unhandled error. Please report it as an issue on Github 🥰")
        ActionsEnvironment.logger.error("Error description: \(message)")
        ActionsEnvironment.logger.error("Stacktrace:\n\(stackTrace)")
    }
}

public enum AppDabError: Error {
    case simpleError(message: String)
    case loggedError(message: String, logFileUrl: URL)
    case unhandledError(message: String, stackTrace: String)
    
    public var message: String {
        switch self {
        case .simpleError(let message), .loggedError(let message, _), .unhandledError(let message, _):
            return message
        }
    }
}

/// Error originating from an action.
public protocol ActionError: Error {
    /// The description of the error
    var description: String { get }
}
