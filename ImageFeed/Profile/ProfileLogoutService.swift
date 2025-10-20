import Foundation
import WebKit

final class ProfileLogoutService {
    static let shared = ProfileLogoutService()
    
    private init() {}
    
    func logout() {
        clearToken()
        resetServices()
        cleanCookies()
    }
    
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
