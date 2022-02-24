import Foundation

internal extension Data {
    var hexadecimalString: String {
        return self.map { String(format: "%02hhx", $0) }.joined()
    }
}
