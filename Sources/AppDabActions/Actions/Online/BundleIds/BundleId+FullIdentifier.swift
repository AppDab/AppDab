import Bagbutik

extension BundleId {
    static func fullIdentifier(for identifier: String, seedId: String?) -> String {
        if let seedId = seedId {
            return "\(seedId).\(identifier)"
        } else {
            return identifier
        }
    }
}
