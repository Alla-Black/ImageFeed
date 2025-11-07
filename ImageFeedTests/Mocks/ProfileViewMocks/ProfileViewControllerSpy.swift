@testable import ImageFeed
import XCTest

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var presenter: ProfilePresenterProtocol?
    var showLoadingSkeletonCalled: Bool = false
    var setAvatarCalled: Bool = false
    var receivedURL: String?
    var setProfileCalled = false
    var receivedName: String?
    var receivedLogin: String?
    var receivedBio: String?
    var hideLoadingSkeletonCalled: Bool = false
    var showLogoutAlertCalled: Bool = false
    var showBlockingHUDCalls: [Bool] = []
    var clearProfileUICalled = false
    var switchToSplashRootCalled = false
    var setAvatarCallCount = 0
    
    func setProfile(name: String?, login: String?, bio: String?) {
        setProfileCalled = true
        receivedName = name
        receivedLogin = login
        receivedBio = bio
        
    }
    
    func setAvatar(urlString: String?) {
        setAvatarCalled = true
        receivedURL = urlString
        setAvatarCallCount += 1
    }
    
    func showLogoutAlert() {
        showLogoutAlertCalled = true
    }
    
    func showBlockingHUD(_ show: Bool) {
        showBlockingHUDCalls.append(show)
    }
    
    func clearProfileUI() {
        clearProfileUICalled = true
    }
    
    func switchToSplashRoot() {
        switchToSplashRootCalled = true
    }
    
    func showLoadingSkeleton() {
        showLoadingSkeletonCalled = true
    }
    
    func hideLoadingSkeleton() {
        hideLoadingSkeletonCalled = true
    }
}
