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
    
    func viewDidLoad() {
        view?.showLoadingSkeleton()
        
        imageObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) {
            [weak self] notification in
            guard let self else { return }
            
            guard let userInfo = notification.userInfo,
                  let urlString = userInfo["URL"] as? String else { return }
            
            self.view?.setAvatar(urlString: urlString)
        }
        
        if let url = ProfileImageService.shared.avatarURL {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.view?.setAvatar(urlString: url)
            }
        } else {
            view?.setAvatar(urlString: nil)
        }
        
        guard let profile = ProfileService.profileService.profile else {
            return
        }
        
        let name = profile.name.isEmpty ? "Имя не указано" : profile.name
        
        let login = profile.loginName.isEmpty ? "@неизвестный_пользователь" : profile.loginName
        
        let bio = (profile.bio?.isEmpty ?? true) ? "Профиль не заполнен" : profile.bio
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.view?.setProfile(name: name, login: login, bio: bio)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                self?.view?.hideLoadingSkeleton()
            }
        }
    }
    
    func didTapLogout() {
        view?.showLogoutAlert()
    }
    
    func confirmLogout() {
        view?.showBlockingHUD(true)
        ProfileLogoutService.shared.logout()
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
