public class Settings {
    public var apiKey: APIKeyResolution = .fromEnvironmentVariables
}

public enum APIKeyResolution {
    case fromEnvironmentVariables
    case fromKeychain(_ keyId: String)
}
