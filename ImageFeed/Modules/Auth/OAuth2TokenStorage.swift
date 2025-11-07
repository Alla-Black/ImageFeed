import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    
    // MARK: - Singleton
    static let shared = OAuth2TokenStorage()
    private init() {}
    
    // MARK: - Public Properties
    var token: String? {
        get {
            KeychainWrapper.standard.string(forKey: key)
        }
        set {
            if let token = newValue{
                KeychainWrapper.standard.set(token, forKey: key)
            } else {
                KeychainWrapper.standard.removeObject(forKey: key)
            }
        }
    }
    
    // MARK: - Private Properties
    private let key = "BearerToken"
}
