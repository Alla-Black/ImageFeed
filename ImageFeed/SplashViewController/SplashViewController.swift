import UIKit

final class SplashViewController: UIViewController {
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    private var hasPresentedAuth = false
    private var launchIcon: UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(named: "YP Black")
        
        addViewsToScreen()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
            if let token = OAuth2TokenStorage.shared.token {
                // Пользователь авторизован
                fetchProfile(token: token)
                return
                
            } else {
                // Пользователь не авторизован, переход на экран авторизации
                presentAuthViewController()
            }
        }
    
    private func addViewsToScreen() {
        let launchIcon = UIImageView(image: UIImage(named: "launch_Icon"))
        
        launchIcon.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(launchIcon)
        
        NSLayoutConstraint.activate([
            launchIcon.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            launchIcon.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func presentAuthViewController() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
       guard let authViewController = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else {
           assertionFailure("Couldn't find AuthViewController by ID")
           return
        }
        
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true)
    }
    
    private func  switchToTabBarController() {
        guard
            let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarController")
        
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
    
    private func fetchProfile(token: String) {
        UIBlockingProgressHUD.show()
        
        ProfileService.profileService.fetchProfile(token) { [weak self] result in
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                guard let self else { return }
                
                switch result {
                case let .success(profile):
                    ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { _ in }
                    self.switchToTabBarController()
                
                case let .failure(error):
                    print("Failed to fetch profile: \(error)")
                    break
                }
            }
        }
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true)
        
        guard let token = OAuth2TokenStorage.shared.token else {
            print("Error: missing OAuth token after auth")
            return
        }
        fetchProfile(token: token)
    }
}
