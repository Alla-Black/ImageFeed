@testable import ImageFeed
import XCTest

final class ProfileViewTests: XCTestCase {
    func testProfileViewControllerCallsViewDidLoad() {
        //given
        let sut = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        
        sut.configure(presenter)
        
        //when
        sut.viewDidLoad()
        
        //then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testPresenterCallsShowLoadingSkeleton() {
        //given
        let presenter = ProfilePresenter()
        let viewSpy = ProfileViewControllerSpy()
        
        presenter.view = viewSpy
        
        //when
        presenter.viewDidLoad()
        
        //then
        XCTAssertTrue(viewSpy.showLoadingSkeletonCalled)
    }
}

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol?
    var viewDidLoadCalled: Bool = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didTapLogout() {
        
    }
    
    func confirmLogout() {
        
    }
}

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var presenter: ProfilePresenterProtocol?
    var showLoadingSkeletonCalled: Bool = false
    
    func setProfile(name: String?, login: String?, bio: String?) {
        
    }
    
    func setAvatar(urlString: String?) {
        
    }
    
    func showLogoutAlert() {
        
    }
    
    func showBlockingHUD(_ show: Bool) {
        
    }
    
    func clearProfileUI() {
        
    }
    
    func switchToSplashRoot() {
        
    }
    
    func showLoadingSkeleton() {
        showLoadingSkeletonCalled = true
    }
    
    func hideLoadingSkeleton() {
        
    }
}
