@testable import ImageFeed
import XCTest

final class ProfileLogoutServiceSpy: ProfileLogoutServiceProtocol {
    var logoutCalled: Bool = false
    
    func logout() {
        logoutCalled = true
    }
}

