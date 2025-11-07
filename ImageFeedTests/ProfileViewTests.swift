@testable import ImageFeed
import XCTest

final class ProfileViewTests: XCTestCase {
    func testProfileViewControllerCallsViewDidLoad() {
        //Given
        let sut = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        
        sut.configure(presenter)
        
        //When
        sut.viewDidLoad()
        
        //Then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testPresenterCallsShowLoadingSkeleton() {
        //Given
        let presenter = ProfilePresenter()
        let viewSpy = ProfileViewControllerSpy()
        
        presenter.view = viewSpy
        
        //When
        presenter.viewDidLoad()
        
        //Then
        XCTAssertTrue(viewSpy.showLoadingSkeletonCalled)
    }
    
    func testPresenterCallsSetAvatar() {
        //Given
        let imageStub = ProfileImageServiceStub()
        imageStub.avatarURL = "https://example.com/avatar.png"
        
        let presenter = ProfilePresenter(imageService: imageStub)
        let viewSpy = ProfileViewControllerSpy()
        presenter.view = viewSpy
        
        //When
        presenter.viewDidLoad()
        
        //Then
        let exp = expectation(description: "wait for setAvatar")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertTrue(viewSpy.setAvatarCalled)
        XCTAssertEqual(viewSpy.receivedURL, "https://example.com/avatar.png")
    }
    
    func testPresenterCallsSetProfile() {
        //Given
        let profileStub = ProfileServiceStub()
        profileStub.profile = Profile(
            username: "testUser",
            name: "Имя",
            loginName: "@login",
            bio: "Описание"
        )
        
        let presenter = ProfilePresenter(profileService: profileStub)
        let viewSpy = ProfileViewControllerSpy()
        presenter.view = viewSpy
        
        //When
        presenter.viewDidLoad()
        
        //Then
        let exp = expectation(description: "wait setProfile")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertTrue(viewSpy.setProfileCalled)
        XCTAssertEqual(viewSpy.receivedName, "Имя")
        XCTAssertEqual(viewSpy.receivedLogin, "@login")
        XCTAssertEqual(viewSpy.receivedBio, "Описание")
    }
    
    func testPresenterHideLoadingSkeleton() {
        //Given
        let profileStub = ProfileServiceStub()
        profileStub.profile = Profile(
            username: "testUser",
            name: "Имя",
            loginName: "@login",
            bio: "Описание"
        )
        
        let presenter = ProfilePresenter(profileService: profileStub)
        let viewSpy = ProfileViewControllerSpy()
        presenter.view = viewSpy
        
        //When
        presenter.viewDidLoad()
        
        //Then
        let exp = expectation(description: "wait hideLoadingSkeleton")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertTrue(viewSpy.hideLoadingSkeletonCalled)
    }
    
    func testPresenterShowLogoutAlert() {
        //Given
        let presenter = ProfilePresenter()
        let viewSpy = ProfileViewControllerSpy()
        presenter.view = viewSpy
        
        //When
        presenter.didTapLogout()
        
        //Then
        XCTAssertTrue(viewSpy.showLogoutAlertCalled)
    }
    
    func testPresenterConfirmLogoutCallsAllExpectedActions() {
        // Given
        let logoutSpy = ProfileLogoutServiceSpy()
        let viewSpy = ProfileViewControllerSpy()
        let presenter = ProfilePresenter(profileLogoutService: logoutSpy)
        presenter.view = viewSpy
        
        // When
        presenter.confirmLogout()
        
        // Then
        XCTAssertEqual(viewSpy.showBlockingHUDCalls, [true, false])
        XCTAssertTrue(logoutSpy.logoutCalled)
        XCTAssertTrue(viewSpy.clearProfileUICalled)
        XCTAssertTrue(viewSpy.switchToSplashRootCalled)
    }
    
    func testPresenterSetsNilAvatarWhenNoURL() {
        //Given
        let imageStub = ProfileImageServiceStub()
        let presenter = ProfilePresenter(imageService: imageStub)
        
        let viewSpy = ProfileViewControllerSpy(); presenter.view = viewSpy
        
        //When
        presenter.viewDidLoad()
        
        //Then
        XCTAssertTrue(viewSpy.setAvatarCalled)
        XCTAssertNil(viewSpy.receivedURL)
        XCTAssertEqual(viewSpy.setAvatarCallCount, 1)
    }
    
    func testPresenterReceivesAvatarUpdateViaNotification() {
        //Given
        let imageStub = ProfileImageServiceStub()
        
        let presenter = ProfilePresenter(imageService: imageStub)
        let viewSpy = ProfileViewControllerSpy()
        
        presenter.view = viewSpy
        presenter.viewDidLoad()
        
        //When
        NotificationCenter.default.post(
            name: imageStub.didChangeNotification,
            object: nil,
            userInfo: ["URL": "https://new.url"]
        )
        
        //Then
        XCTAssertEqual(viewSpy.receivedURL, "https://new.url")
    }
    
    func testPresenterFormatsEmptyProfileFieldsWithPlaceholders() {
        // Given
        let profileStub = ProfileServiceStub()
        profileStub.profile = Profile(
            username: "testUser",
            name: "",
            loginName: "",
            bio: ""
        )
        
        let presenter = ProfilePresenter(profileService: profileStub)
        let viewSpy = ProfileViewControllerSpy()
        presenter.view = viewSpy
        
        // When
        presenter.viewDidLoad()
        
        // Then
        let exp = expectation(description: "wait placeholders")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(viewSpy.receivedName, "Имя не указано")
        XCTAssertEqual(viewSpy.receivedLogin, "@неизвестный_пользователь")
        XCTAssertEqual(viewSpy.receivedBio, "Профиль не заполнен")
    }
    
}
