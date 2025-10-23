import UIKit
import ProgressHUD

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}

final class AuthViewController: UIViewController {
    
    @IBOutlet private weak var loginButton: UIButton!
    
    private let showWebViewSegueIdentifier = "ShowWebView"
    
    weak var delegate: AuthViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        
        configureBackButton ()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebViewSegueIdentifier {
            guard let webViewViewController = segue.destination as? WebViewViewController
            else {
                assertionFailure("Failed to prepare for \(showWebViewSegueIdentifier)")
                return
                }
            let webViewPresenter = WebViewPresenter()
            webViewViewController.presenter = webViewPresenter
            webViewPresenter.view = webViewViewController
            
            webViewViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    private func configureBackButton () {
        navigationController?.navigationBar.backIndicatorImage = UIImage(resource: .navBackButton)
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(resource: .navBackButton)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(resource: .ypBlack)
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
    
        print("Получили код авторизации: \(code)")
        
        navigationController?.popViewController(animated: true)
    
        UIBlockingProgressHUD.show()
    
        OAuth2Service.shared.fetchAuthToken(code: code) { [weak self] result in
            
            UIBlockingProgressHUD.dismiss()
            
            guard let self else { return }
            
            switch result {
            case .success(let token):
                
                print("Токен: \(token)")
                self.delegate?.didAuthenticate(self)
            
            case .failure(let error):
                print(error)
                
                let alert = UIAlertController(title: "Что-то пошло не так(", message: "Не удалось войти в систему", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                if self.presentedViewController == nil {
                    self.present(alert, animated: true)
                }
            }
        }
}
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        print("Пользователь отменил авторизацию")
        dismiss(animated: true)
    }
}

