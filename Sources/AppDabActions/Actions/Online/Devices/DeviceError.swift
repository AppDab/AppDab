public enum DeviceError: ActionError {
    case deviceWitNameNotFound
    
    public var description: String {
        switch self {
        case .deviceWitNameNotFound:
            return "Device with name not found"
        }
    }
}
