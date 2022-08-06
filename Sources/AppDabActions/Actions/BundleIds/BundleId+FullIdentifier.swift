import Bagbutik_Models

internal extension BundleId {
    static func fullIdentifier(for identifier: String, seedId: String?) -> String {
        if let seedId = seedId, seedId.lengthOfBytes(using: .utf8) > 0 {
            return "\(seedId).\(identifier)"
        }
        return identifier
    }
}
