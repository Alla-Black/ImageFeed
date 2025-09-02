import Foundation
import UIKit

final class AuthViewController: UIViewController {
    
    @IBOutlet weak var loginButton: UIButton!
    
    private let showWebViewSegueIdentifier = "ShowWebView"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        
        configureBackButton ()
    }
    
    private func configureBackButton () {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "YP Black")
    }
}
