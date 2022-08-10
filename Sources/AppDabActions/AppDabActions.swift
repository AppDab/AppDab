import Bagbutik_Core
import Foundation

/**
 Map any error to an `AppDabError`.
 
 If the error is unknown, and thus unhandled a stack trace is included.
 
 - Parameters:
    - error: The error to map.
 - Returns: An `AppDabError`.
 */
public func mapErrorToAppDabError(error: Error) -> AppDabError {
    if let error = error as? ServiceError, let description = error.description {
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

/**
 Log an `AppDabError`.
 
 If the error is an `.unhandledError` the user is asked to report it on GitHub.
 
 - Parameters:
    - error: The `AppDabError`.
 */
public func logAppDabError(_ error: AppDabError) {
    switch error {
    case .simpleError(let message):
        ActionsEnvironment.logger.error("💥 \(message)")
    case .loggedError(let message, let logFileUrl):
        ActionsEnvironment.logger.error("💥 \(message)")
        ActionsEnvironment.logger.error("The full log is here: \(logFileUrl)")
    case .unhandledError(let message, let stackTrace):
        ActionsEnvironment.logger.error("💥 Unhandled error. Please report it as an issue on GitHub 🥰")
        ActionsEnvironment.logger.error("Error description: \(message)")
        ActionsEnvironment.logger.error("Stacktrace:\n\(stackTrace)")
    }
}

/// A mapped error for easier logging.
public enum AppDabError: Error {
    /// A simple error with just a message.
    case simpleError(message: String)
    /// A logged error with a message and an URL for the log file produced.
    case loggedError(message: String, logFileUrl: URL)
    /// An unhandled error with a message and a stack trace.
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
