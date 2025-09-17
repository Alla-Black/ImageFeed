import Foundation

class OAuth2TokenStorage {
    private let key = "BearerToken"
    
    var token: String? {
        get {
            return UserDefaults.standard.string(forKey: key)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}
