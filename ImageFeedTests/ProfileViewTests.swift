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
        
        XCTAssertTrue(viewSpy.setAvatarCalled)
        XCTAssertEqual(viewSpy.receivedURL, "https://example.com/avatar.png")
    }
    
    func testPresenterCallsSetProfile() {
        //given
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
        
        //when
        presenter.viewDidLoad()
        
        //then
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
        //given
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
        
        //when
        presenter.viewDidLoad()
        
        //then
        let exp = expectation(description: "wait hideLoadingSkeleton")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertTrue(viewSpy.hideLoadingSkeletonCalled)
    }
    
    func testPresenterShowLogoutAlert() {
        //given
        let presenter = ProfilePresenter()
        let viewSpy = ProfileViewControllerSpy()
        presenter.view = viewSpy
        
        //when
        presenter.didTapLogout()
        
        //then
        XCTAssertTrue(viewSpy.showLogoutAlertCalled)
    }
    
    func testPresenterConfirmLogoutCallsAllExpectedActions() {
        // given
        let logoutSpy = ProfileLogoutServiceSpy()
        let viewSpy = ProfileViewControllerSpy()
        let presenter = ProfilePresenter(profileLogoutService: logoutSpy)
        presenter.view = viewSpy
        
        // when
        presenter.confirmLogout()
        
        // then
        XCTAssertEqual(viewSpy.showBlockingHUDCalls, [true, false])
        XCTAssertTrue(logoutSpy.logoutCalled)
        XCTAssertTrue(viewSpy.clearProfileUICalled)
        XCTAssertTrue(viewSpy.switchToSplashRootCalled)
    }
    
    func testPresenterSetsNilAvatarWhenNoURL() {
        //given
        let imageStub = ProfileImageServiceStub()
        let presenter = ProfilePresenter(imageService: imageStub)
        
        let viewSpy = ProfileViewControllerSpy(); presenter.view = viewSpy
        
        //when
        presenter.viewDidLoad()
        
        //then
        XCTAssertTrue(viewSpy.setAvatarCalled)
        XCTAssertNil(viewSpy.receivedURL)
        XCTAssertEqual(viewSpy.setAvatarCallCount, 1)
    }
    
    func testPresenterReceivesAvatarUpdateViaNotification() {
        //given
        let imageStub = ProfileImageServiceStub()
        
        let presenter = ProfilePresenter(imageService: imageStub)
        let viewSpy = ProfileViewControllerSpy()
        
        presenter.view = viewSpy
        presenter.viewDidLoad()
        
        //when
        NotificationCenter.default.post(
            name: imageStub.didChangeNotification,
            object: nil,
            userInfo: ["URL": "https://new.url"]
        )
        
        //then
        XCTAssertEqual(viewSpy.receivedURL, "https://new.url")
    }
    
    func testPresenterFormatsEmptyProfileFieldsWithPlaceholders() {
        // given
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
        
        // when
        presenter.viewDidLoad()
        
        // then
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

final class ProfileImageServiceStub: ProfileImageServiceProtocol {
    var avatarURL: String?
    let didChangeNotification = Notification.Name("ProfileImageServiceStub.didChange")
}

final class ProfileServiceStub: ProfileServiceProtocol {
    var profile: Profile?
}

final class ProfileLogoutServiceSpy: ProfileLogoutServiceProtocol {
    var logoutCalled: Bool = false
    
    func logout() {
        logoutCalled = true
    }
}
