import AppDabActions

/**
 Runs the actions specified in the closure. Any thrown errors will be catched and logged.

 - Parameter actions: A closure with some code calling actions
 */
public func runActions(_ actions: () async throws -> Void) async {
    do {
        try await actions()
    } catch (let error) {
        let runActionsError = mapErrorToAppDabError(error: error)
        logAppDabError(runActionsError)
    }
}
