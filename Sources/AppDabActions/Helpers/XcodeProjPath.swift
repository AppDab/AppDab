internal func getPathContainingXcodeProj(_ xcodeProjPath: String? = nil) -> String {
    guard let xcodeProjPath = xcodeProjPath else { return "." }
    return "\(xcodeProjPath)/.."
}
