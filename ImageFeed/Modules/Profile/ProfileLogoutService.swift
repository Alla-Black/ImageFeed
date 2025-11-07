import Foundation
import WebKit

// MARK: - ProfileLogoutServiceProtocol
protocol ProfileLogoutServiceProtocol {
    func logout()
}

// MARK: - ProfileLogoutService
final class ProfileLogoutService {
    
    // MARK: - Singleton
    static let shared = ProfileLogoutService()
    private init() {}
    
    // MARK: - Public Methods
    func logout() {
        clearToken()
        resetServices()
        cleanCookies()
    }
    
    // MARK: - Private Methods
    private func clearToken() {
        OAuth2TokenStorage.shared.token = nil
    }
    
    private func resetServices() {
        ProfileService.profileService.reset()
        ProfileImageService.shared.reset()
        ImagesListService.shared.reset()
    }
    
    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {} )
            }
        }
    }
}

//MARK: - ProfileLogoutServiceProtocol
extension ProfileLogoutService: ProfileLogoutServiceProtocol {}
