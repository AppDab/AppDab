#if os(macOS)
import Foundation

internal protocol AltoolProtocol {
    func validate(exportedArchivePath: String) throws
    func upload(exportedArchivePath: String, appAppleId: String) throws
}

internal struct Altool: AltoolProtocol {
    internal var uuidCreator = { UUID().uuidString }
    internal var fileLoader = String.init(contentsOf:)

    internal func validate(exportedArchivePath: String) throws {
        var parameters = [
            "--validate-app",
            "-f '\(exportedArchivePath)'"
        ]
        if exportedArchivePath.hasSuffix(".ipa") {
            parameters.append("--type ios")
        } else {
            parameters.append("--type osx")
        }
        try execute(
            extraParameters: parameters,
            beginLog: "🚀 Validating exported archive...",
            endLog: "🎉 Archive validated"
        )
    }

    internal func upload(exportedArchivePath: String, appAppleId: String) throws {
        var parameters = [
            "--upload-package '\(exportedArchivePath)'",
            "--apple-id '\(appAppleId)'"
        ]

        let unpackedFolderUrl = ActionsEnvironment.fileManager.temporaryDirectory.appendingPathComponent(uuidCreator())
        ActionsEnvironment.logger.debug("📦 Unpacking package to temporary folder '\(unpackedFolderUrl.path)'...")

        let packageInfo: (bundleId: String, bundleShortVersionString: String, bundleVersion: String)
        if exportedArchivePath.hasSuffix(".ipa") {
            parameters.append("--type ios")
            try ActionsEnvironment.shell.run("unzip \(exportedArchivePath) -d \(unpackedFolderUrl.path)")
            guard let appFolder = try ActionsEnvironment.fileManager
                .contentsOfDirectory(atPath: unpackedFolderUrl.appendingPathComponent("Payload").path)
                .first(where: { $0.hasSuffix(".app") }),
                let infoPlistString = try? fileLoader(unpackedFolderUrl.appendingPathComponent("Payload/\(appFolder)/Info.plist")),
                let infoPlistData = infoPlistString.data(using: .utf8),
                let infoPlist = try? PropertyListSerialization.propertyList(from: infoPlistData, format: nil) as? [String: Any],
                let bundleShortVersionString = infoPlist["CFBundleShortVersionString"] as? String,
                let bundleVersion = infoPlist["CFBundleVersion"] as? String,
                let bundleId = infoPlist["CFBundleIdentifier"] as? String
            else {
                throw UploadError.couldNotReadiOSPackageInfo
            }
            packageInfo = (bundleId: bundleId, bundleShortVersionString: bundleShortVersionString, bundleVersion: bundleVersion)
        } else {
            parameters.append("--type osx")
            try ActionsEnvironment.shell.run("pkgutil --expand \(exportedArchivePath) \(unpackedFolderUrl.path)")
            guard let distributionInfo = try? fileLoader(unpackedFolderUrl.appendingPathComponent("Distribution")),
                  let bundleShortVersionString = distributionInfo.firstMatch(forRegexPattern: #"CFBundleShortVersionString="([^"]*)""#),
                  let bundleVersion = distributionInfo.firstMatch(forRegexPattern: #"CFBundleVersion="([^"]*)""#),
                  let bundleId = distributionInfo.firstMatch(forRegexPattern: #"<bundle.* id="([^"]*)""#)
            else {
                throw UploadError.couldNotReadMacPackageInfo
            }
            packageInfo = (bundleId: bundleId, bundleShortVersionString: bundleShortVersionString, bundleVersion: bundleVersion)
        }
        ActionsEnvironment.logger.info("👍 Read info from package. Bundle ID '\(packageInfo.bundleId)', version string '\(packageInfo.bundleShortVersionString)' and bundle version '\(packageInfo.bundleVersion)'")
        parameters.append("--bundle-short-version-string '\(packageInfo.bundleShortVersionString)'")
        parameters.append("--bundle-version '\(packageInfo.bundleVersion)'")
        parameters.append("--bundle-id '\(packageInfo.bundleId)'")
        try execute(
            extraParameters: parameters,
            beginLog: "🚀 Uploading exported archive...",
            endLog: "🎉 Archive uploaded"
        )
    }

    private func execute(extraParameters: [String], beginLog: String, endLog: String) throws {
        let privateKeyFolderPath = ActionsEnvironment.fileManager.temporaryDirectory.path
        ActionsEnvironment.logger.debug("🔐 Copying private key to temporary folder '\(privateKeyFolderPath)'...")
        let privateKeyFilePath = "\(privateKeyFolderPath)/AuthKey_\(ActionsEnvironment.apiKey.keyId).p8"
        guard ActionsEnvironment.fileManager.createFile(atPath: privateKeyFilePath,
                                                        contents: ActionsEnvironment.apiKey.privateKey.data(using: .utf8),
                                                        attributes: nil) else {
            throw UploadError.couldNotSavePrivateKeyFile
        }
        ActionsEnvironment.logger.debug("👍 Private key saved")

        func deleteTemporaryPrivateKey() throws {
            ActionsEnvironment.logger.debug("🔐 Deleting private key from temporary folder...")
            try ActionsEnvironment.fileManager.removeItem(atPath: privateKeyFilePath)
            ActionsEnvironment.logger.debug("👍 Private key deleted from temporary folder")
        }

        ActionsEnvironment.logger.info(.init(stringLiteral: beginLog))
        let apiKey = ActionsEnvironment.apiKey
        let parameters = extraParameters + [
            "--apiKey '\(apiKey.keyId)'",
            "--apiIssuer '\(apiKey.issuerId)'",
            "-API_PRIVATE_KEYS_DIR '\(privateKeyFolderPath)'"
        ]
        do {
            try ActionsEnvironment.shell.run("xcrun altool \(parameters.joined(separator: " "))")
            ActionsEnvironment.logger.info(.init(stringLiteral: endLog))
        } catch {
            try deleteTemporaryPrivateKey()
            throw error
        }
        try deleteTemporaryPrivateKey()
    }
}

fileprivate extension String {
    var fullRange: NSRange {
        NSRange(startIndex ..< endIndex, in: self)
    }

    func firstMatch(forRegexPattern regexPattern: String) -> String? {
        guard let nsRange = try? NSRegularExpression(pattern: regexPattern)
            .firstMatch(in: self, range: fullRange)?.range(at: 1),
            let range = Range(nsRange, in: self) else {
            return nil
        }
        return String(self[range])
    }
}
#endif
