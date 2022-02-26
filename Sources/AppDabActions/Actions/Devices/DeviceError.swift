/// Error happening when manipulating devices.
public enum DeviceError: ActionError {
    /// The device with name not found.
    case deviceWitNameNotFound
    
    public var description: String {
        switch self {
        case .deviceWitNameNotFound:
            return "Device with name not found"
        }
    }
}
