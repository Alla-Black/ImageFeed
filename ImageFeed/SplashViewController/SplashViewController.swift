import UIKit

final class SplashViewController: UIViewController {
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    private var hasPresentedAuth = false
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
            if let token = OAuth2TokenStorage.shared.token {
                // Пользователь авторизован
                fetchProfile(token: token)
                return
                
            } else {
                // Пользователь не авторизован, переход на экран авторизации
                performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
            }
        }
    
    private func fetchProfile(token: String) {
        UIBlockingProgressHUD.show()
        
        ProfileService.profileService.fetchProfile(token) { [weak self] result in
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                guard let self else { return }
                
                switch result {
                case .success:
                    self.switchToTabBarController()
                
                case .failure(let error):
                    print("Failed to fetch profile: \(error)")
                    break
                }
            }
        }
    }
    
    private func  switchToTabBarController() {
        guard
            let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showAuthenticationScreenSegueIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers.first as? AuthViewController
            else {
                assertionFailure("Failed to prepare for \(showAuthenticationScreenSegueIdentifier)")
                return
            }
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}
