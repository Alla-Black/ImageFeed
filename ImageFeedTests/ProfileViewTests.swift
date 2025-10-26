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
    
    func testPresenterCallsSetAvatar() {
        //given
        let imageStub = ProfileImageServiceStub()
        imageStub.avatarURL = "https://example.com/avatar.png"
        
        let presenter = ProfilePresenter(imageService: imageStub)
        let viewSpy = ProfileViewControllerSpy()
        presenter.view = viewSpy
        
        //when
        presenter.viewDidLoad()
        
        // then
        let exp = expectation(description: "wait for setAvatar")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        
        //then
        XCTAssertTrue(viewSpy.setAvatarCalled)
        XCTAssertEqual(viewSpy.receivedURL, "https://example.com/avatar.png")
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
    var setAvatarCalled: Bool = false
    var receivedURL: String?
    
    func setProfile(name: String?, login: String?, bio: String?) {
        
    }
    
    func setAvatar(urlString: String?) {
        setAvatarCalled = true
        receivedURL = urlString
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

final class ProfileImageServiceStub: ProfileImageServiceProtocol {
    var avatarURL: String?
    let didChangeNotification = Notification.Name("ProfileImageServiceStub.didChange")
}
