#if os(macOS)
/**
 Run tests for a scheme in a project
 
 - Parameter xcodeProjPath: The path to a specific Xcode project. If this is not specified, it will look in the current directory.
 - Parameter schemeName: The name of the scheme to test. If this is not specified, it will look for a scheme matching the name of the project or let the user select from a list.
 */
public func runTests(xcodeProjPath: String? = nil, schemeName: String? = nil) throws {
    ActionsEnvironment.logger.info("🧪 Running tests...")
    let path = getPathContainingXcodeProj(xcodeProjPath)
    let scheme = try schemeName ?? ActionsEnvironment.xcodebuild.findSchemeName(at: path)
    let output = try ActionsEnvironment.shell.run("xcodebuild test -scheme '\(scheme)' -destination 'platform=iOS Simulator,name=iPhone 12 Pro'", outputCallback: {
        if $0 == "" { ActionsEnvironment.logger.info("\($0)") }
        else if let parsedLine = ActionsEnvironment.parseXcodebuildOutput($0, true) { ActionsEnvironment.logger.info("\(parsedLine)") }
    })
    guard let xcresultPath = output.split(separator: "\n").last(where: { $0.hasSuffix(".xcresult") })?
        .trimmingCharacters(in: .whitespaces)
    else {
        throw XcodebuildError.testResultNotFound
    }
    ActionsEnvironment.logger.trace("The test result is here: \(xcresultPath)")
    let html = ActionsEnvironment.generateTestResultHtmlReport(xcresultPath)
    let reportPath = "\(path)/TestResult.html"
    try ActionsEnvironment.writeStringFile(html, reportPath)
    ActionsEnvironment.logger.info("🎉 Test finished running. The report is here: \(reportPath)")
}
#endif
