import Foundation

public protocol ProfilePresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    
    func viewDidLoad()
    func didTapLogout()
    func confirmLogout()
}

final class ProfilePresenter: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    private var imageObserver: NSObjectProtocol?
    
    private let imageService: ProfileImageServiceProtocol
    private let profileService: ProfileServiceProtocol
    private let profileLogoutService: ProfileLogoutServiceProtocol
    
    init(
        imageService: ProfileImageServiceProtocol = ProfileImageService.shared,
        profileService: ProfileServiceProtocol = ProfileService.profileService,
        profileLogoutService: ProfileLogoutServiceProtocol = ProfileLogoutService.shared
    ) {
        self.imageService = imageService
        self.profileService = profileService
        self.profileLogoutService = profileLogoutService
    }
    
    func viewDidLoad() {
        view?.showLoadingSkeleton()
        
        imageObserver = NotificationCenter.default.addObserver(
            forName: imageService.didChangeNotification,
            object: nil,
            queue: .main
        ) {
            [weak self] notification in
            guard let self else { return }
            
            guard let userInfo = notification.userInfo,
                  let urlString = userInfo["URL"] as? String else { return }
            
            self.view?.setAvatar(urlString: urlString)
        }
        
        if let url = imageService.avatarURL {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.view?.setAvatar(urlString: url)
            }
        } else {
            view?.setAvatar(urlString: nil)
        }
        
        guard let profile = profileService.profile else {
            return
        }
        
        let name = profile.name.isEmpty ? "Имя не указано" : profile.name
        
        let login = profile.loginName.isEmpty ? "@неизвестный_пользователь" : profile.loginName
        
        let bio = (profile.bio?.isEmpty ?? true) ? "Профиль не заполнен" : profile.bio
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self else { return }
            self.view?.setProfile(name: name, login: login, bio: bio)
            self.view?.hideLoadingSkeleton()
        }
    }
    
    func didTapLogout() {
        view?.showLogoutAlert()
    }
    
    func confirmLogout() {
        view?.showBlockingHUD(true)
        profileLogoutService.logout()
        view?.clearProfileUI()
        view?.showBlockingHUD(false)
        view?.switchToSplashRoot()
    }
    
    deinit {
        if let imageObserver {
            NotificationCenter.default.removeObserver(imageObserver)
        }
    }
}
