import CoreFoundation
public enum CertificateError: ActionError, Equatable {
    case certificateWithSerialNumberNotFound(String)
    case certificateWithNameNotFound(String)

    case errorReadingFromKeychain
    case privateKeyForCertificateNotFound
    case errorAddingCertificateToKeychain
    case errorExportingFromKeychain
    case invalidOnlineCertificateData
    case errorImportingP12
    case typeCantBeCreated
    case errorCreatingPublicKey
    case errorCreatingSigningRequest

    public var description: String {
        switch self {
        case .certificateWithSerialNumberNotFound(let serialNumber):
            return "Certificate '\(serialNumber)' not found"
        case .certificateWithNameNotFound(let name):
            return "Certificate named '\(name)' not found"
        case .errorReadingFromKeychain:
            return "An error occurred when reading from Keychain"
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
        case .typeCantBeCreated:
            return "The type of certificate specified can't be created"
        case .errorCreatingPublicKey:
            return "Could not create public key"
        case .errorCreatingSigningRequest:
            return "Could not create signing request"
        }
    }
}

public enum AddCertificateToKeychainError: ActionError, Equatable {
    case invalidOnlineCertificateData
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
