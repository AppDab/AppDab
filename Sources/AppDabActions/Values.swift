/// Values to be shared between actions
public class Values {
    /// Path to the built Xcode archive
    public internal(set) var xcarchivePath: String?

    /// Path to the exported .ipa file
    public internal(set) var ipaPath: String?
    /// Path to the exported .pkg file
    public internal(set) var pkgPath: String?
    /// Path to the exported archive
    public internal(set) var exportedArchivePath: String? {
        get { ipaPath ?? pkgPath }
        set {
            guard let newValue = newValue else { return }
            if newValue.hasSuffix(".ipa") {
                ipaPath = newValue
            } else if newValue.hasSuffix(".pkg") {
                pkgPath = newValue
            }
        }
    }
}
