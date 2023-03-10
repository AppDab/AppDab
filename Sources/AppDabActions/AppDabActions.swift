import Bagbutik_Core
import Foundation

/**
 Map any error to an `AppDabError`.

 If the error is unknown, and thus unhandled a stack trace is included.

 - Parameters:
    - error: The error to map.
 - Returns: An `AppDabError`.
 */
public func mapErrorToAppDabError(error: Error, parseAppStoreConnectErrors: Bool = true) -> AppDabError {
    if let firstError = (error as? ServiceError)?.errorResponse?.errors?.first {
        if let associatedErrors = firstError.meta?.associatedErrors?.values.flatMap({ $0 }) {
            return .errorWithAssociatedErrors(message: firstError.parsedDetail, associatedMessages: associatedErrors.map {
                if parseAppStoreConnectErrors { return $0.parsedDetail }
                else { return $0.detail ?? $0.title }
            }.unique)
        } else {
            return .simpleError(message: parseAppStoreConnectErrors
                ? firstError.parsedDetail
                : firstError.detail ?? firstError.title)
        }
    } else if let error = error as? ServiceError {
        return .simpleError(message: error.description!)
    } else if let error = error as? ActionError {
        return .simpleError(message: error.description)
    } else if let error = error as? LocalizedError, let message = error.errorDescription {
        return .simpleError(message: message)
    } else if let error = error as? ShellError {
        return .loggedError(message: error.message, logFileUrl: error.logFileUrl)
    } else if (error as NSError).domain == NSURLErrorDomain, (error as NSError).code == -999 {
        return .cancelled
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
    case .errorWithAssociatedErrors(let message, let associatedMessages):
        ActionsEnvironment.logger.error("💥 \(message)")
        ActionsEnvironment.logger.error("\(associatedMessages.map { "• \($0)" }.joined(separator: "\n"))")
    case .loggedError(let message, let logFileUrl):
        ActionsEnvironment.logger.error("💥 \(message)")
        ActionsEnvironment.logger.error("The full log is here: \(logFileUrl)")
    case .cancelled:
        break
    case .unhandledError(let message, let stackTrace):
        ActionsEnvironment.logger.error("💥 Unhandled error. Please report it as an issue on GitHub 🥰")
        ActionsEnvironment.logger.error("Error description: \(message)")
        ActionsEnvironment.logger.error("Stacktrace:\n\(stackTrace)")
    }
}

/// A mapped error for easier logging.
public enum AppDabError: Error, Equatable {
    /// A simple error with just a message.
    case simpleError(message: String)
    /// An error which has one or more associated/sub errors.
    case errorWithAssociatedErrors(message: String, associatedMessages: [String])
    /// A logged error with a message and an URL for the log file produced.
    case loggedError(message: String, logFileUrl: URL)
    /// The actions was cancelled
    case cancelled
    /// An unhandled error with a message and a stack trace.
    case unhandledError(message: String, stackTrace: String)

    public var message: String {
        switch self {
        case .simpleError(let message), .loggedError(let message, _), .unhandledError(let message, _):
            return message
        case .cancelled:
            return "Cancelled"
        case .errorWithAssociatedErrors(let message, associatedMessages: let associatedMessages):
            return message + "\n" + associatedMessages.map { "• \($0)" }.joined(separator: "\n")
        }
    }
}

/// Error originating from an action.
public protocol ActionError: Error {
    /// The description of the error
    var description: String { get }
}

private extension Sequence where Iterator.Element: Hashable {
    var unique: [Iterator.Element] {
        var seen: Set<Iterator.Element> = []
        return filter {
            print(seen, $0)
            let result = seen.insert($0)
            print("inserted", result.inserted)
            return result.inserted
        }
    }
}
