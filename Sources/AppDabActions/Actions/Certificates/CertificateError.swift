import Foundation

/// Error happening when handling certificates.
public enum CertificateError: ActionError, Equatable {
    /// Certificate with the serial number not found.
    case certificateWithSerialNumberNotFound(String)
    /// Certificate with the name not found.
    case certificateWithNameNotFound(String)

    /// Error occurred when reading from Keychain.
    case errorReadingFromKeychain(OSStatus)
    /// The private key for the certificate was not found.
    case privateKeyForCertificateNotFound
    /// An error occurred when adding certificate to Keychain.
    case errorAddingCertificateToKeychain
    /// An error occurred when exporting certificate and private key.
    case errorExportingFromKeychain
    /// The certificate fetched from App Store Connect is incomplete.
    case invalidOnlineCertificateData
    /// Could not import certificate and private key.
    case errorImportingP12
    /// Could not create public key.
    case errorCreatingPublicKey
    /// Could not create signing request.
    case errorCreatingSigningRequest

    public var description: String {
        switch self {
        case .certificateWithSerialNumberNotFound(let serialNumber):
            return "Certificate '\(serialNumber)' not found"
        case .certificateWithNameNotFound(let name):
            return "Certificate named '\(name)' not found"
        case .errorReadingFromKeychain(let status):
            return "An error occurred when reading from Keychain (OSStatus: \(status))"
        case .privateKeyForCertificateNotFound:
            return "The private key for the certificate was not found"
        case .errorAddingCertificateToKeychain:
            return "An error occurred when adding certificate to Keychain"
        case .errorExportingFromKeychain:
            return "An error occurred when exporting certificate and private key"
        case .invalidOnlineCertificateData:
            return "The certificate fetched from App Store Connect is incomplete"
        case .errorImportingP12:
            return "Could not import certificate and private key"
        case .errorCreatingPublicKey:
            return "Could not create public key"
        case .errorCreatingSigningRequest:
            return "Could not create signing request"
        }
    }
}

/// Error happening when adding certificates to Keychain.
public enum AddCertificateToKeychainError: ActionError, Equatable {
    /// The certificate fetched from App Store Connect is incomplete
    case invalidOnlineCertificateData
    /// An error occurred when adding certificate to Keychain. Lookup the status on <https://osstatus.com>.
    case errorAddingCertificateToKeychain(status: OSStatus)

    public var description: String {
        switch self {
        case .invalidOnlineCertificateData:
            return "The certificate fetched from App Store Connect is incomplete"
        case .errorAddingCertificateToKeychain(let status):
            return "Unknown error occurred when adding certificate to Keychain (OSStatus: \(status))"
        }
    }
}

/// Error happening when creating certificates.
public enum CreateCertificateError: ActionError, Equatable {
    /// Could not create public key.
    case errorCreatingPublicKey
    /// Could not create signing request.
    case errorCreatingSigningRequest

    public var description: String {
        switch self {
        case .errorCreatingPublicKey:
            return "Could not create public key"
        case .errorCreatingSigningRequest:
            return "Could not create signing request"
        }
    }
}
