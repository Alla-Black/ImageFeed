import UIKit
import Kingfisher
import ProgressHUD

public protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfilePresenterProtocol? { get set }
    
    func setProfile(name: String?, login: String?, bio: String?)
    func setAvatar(urlString: String?)
    func showLogoutAlert()
    func showBlockingHUD(_ show: Bool)
    func clearProfileUI()
    func switchToSplashRoot()
    
    func showLoadingSkeleton()
    func hideLoadingSkeleton()
}

final class ProfileViewController: UIViewController {
    private var nameLabel: UILabel?
    private var loginName: UILabel?
    private var descriptionLabel: UILabel?
    private var avatarImage: UIImageView?
    private var logoutButton: UIButton?
    private var profileInformation: [UIView] = []
    
    private let skeleton = SkeletonAnimationService()
    
    private var nameW: NSLayoutConstraint?
    private var loginW: NSLayoutConstraint?
    private var descriptionW: NSLayoutConstraint?
    
    var presenter: ProfilePresenterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(resource: .ypBlack)
        
        addViewsToScreen()
        
        nameLabel?.accessibilityIdentifier = "profile_name"
        loginName?.accessibilityIdentifier = "profile_login"
        logoutButton?.accessibilityIdentifier = "profile_logout_button"
        
        presenter?.viewDidLoad()
    }
    
    private func addViewsToScreen() {
        let avatarImage = UIImageView(image: UIImage(resource: .emptyAvatar))
        
        let nameLabel = UILabel()
        let loginName = UILabel()
        let descriptionLabel = UILabel()
        let logoutButton = UIButton.systemButton(
            with: UIImage(resource: .exitButton),
            target: self,
            action: #selector(didTapLogoutButton)
        )
        
        self.nameLabel = nameLabel
        self.loginName = loginName
        self.descriptionLabel = descriptionLabel
        self.avatarImage = avatarImage
        self.logoutButton = logoutButton
        
        profileInformation = [nameLabel, loginName, descriptionLabel, avatarImage]
        
        nameLabel.text = ""
        nameLabel.textColor = UIColor(resource: .ypWhite)
        nameLabel.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        
        loginName.text = ""
        loginName.textColor = UIColor(resource: .ypGray)
        loginName.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        
        descriptionLabel.text = ""
        descriptionLabel.textColor = UIColor(resource: .ypWhite)
        descriptionLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        
        logoutButton.tintColor = UIColor(resource: .ypRed)
        
        avatarImage.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        loginName.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(avatarImage)
        view.addSubview(nameLabel)
        view.addSubview(loginName)
        view.addSubview(descriptionLabel)
        view.addSubview(logoutButton)
        
        nameW = nameLabel.widthAnchor.constraint(equalToConstant: 223)
        loginW = loginName.widthAnchor.constraint(equalToConstant: 89)
        descriptionW = descriptionLabel.widthAnchor.constraint(equalToConstant: 67)
        
        NSLayoutConstraint.activate([
            nameW!,
            nameLabel.heightAnchor.constraint(equalToConstant: 18),
            loginW!,
            loginName.heightAnchor.constraint(equalToConstant: 18),
            descriptionW!,
            descriptionLabel.heightAnchor.constraint(equalToConstant: 18)
        ])
        
        NSLayoutConstraint.activate([
            avatarImage.widthAnchor.constraint(equalToConstant: 70),
            avatarImage.heightAnchor.constraint(equalToConstant: 70),
            avatarImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            avatarImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            
            nameLabel.topAnchor.constraint(equalTo: avatarImage.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: avatarImage.leadingAnchor),
            
            loginName.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            loginName.leadingAnchor.constraint(equalTo: avatarImage.leadingAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: loginName.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: avatarImage.leadingAnchor),
            
            logoutButton.widthAnchor.constraint(equalToConstant: 44),
            logoutButton.heightAnchor.constraint(equalToConstant: 44),
            logoutButton.centerYAnchor.constraint(equalTo: avatarImage.centerYAnchor),
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    @objc private func didTapLogoutButton () {
        presenter?.didTapLogout()
    }
}

// MARK: - ProfileViewControllerProtocol
extension ProfileViewController: ProfileViewControllerProtocol {
    func configure(_ presenter: ProfilePresenterProtocol) {
        self.presenter = presenter
        presenter.view = self
    }
    
    func setProfile(name: String?, login: String?, bio: String?) {
        nameLabel?.text = name
        if let nameLabel {
            skeleton.stopShimmerAnimation(on: nameLabel)
        }
        
        loginName?.text = login
        if let loginName { skeleton.stopShimmerAnimation(on: loginName)
        }
        
        descriptionLabel?.text = bio
        if let descriptionLabel { skeleton.stopShimmerAnimation(on: descriptionLabel)
        }
        
        [nameW, loginW, descriptionW].forEach { $0?.isActive = false }
    }
    
    func setAvatar(urlString: String?) {
        guard let urlString, let url = URL(string: urlString) else {
            avatarImage?.kf.cancelDownloadTask()
            avatarImage?.image = UIImage(resource: .emptyAvatar)
            return
        }
        
        let processor = RoundCornerImageProcessor(cornerRadius: 35)
        avatarImage?.kf.indicatorType = .activity
        avatarImage?.kf.setImage(with: url,
                                 placeholder: UIImage(resource: .emptyAvatar),
                                 options: [.processor(processor),
                                           .scaleFactor(UIScreen.main.scale),
                                           .cacheOriginalImage,
                                           .forceRefresh
                                 ]) { [weak self] result in
            
            if let avatar = self?.avatarImage {
                self?.skeleton.stopShimmerAnimation(on: avatar)
            }
        }
    }
    
    func showLogoutAlert() {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert
        )
        
        let logoutAction = UIAlertAction(title: "Да", style: .default) { [weak self] _ in
            self?.presenter?.confirmLogout()
            }
            
            let cancelAction = UIAlertAction(title: "Нет", style: .default)
            
            alert.addAction(logoutAction)
            alert.addAction(cancelAction)
            
            present(alert, animated: true)
        }
    
    func showBlockingHUD(_ show: Bool) {
        if show {
            UIBlockingProgressHUD.show()
        } else {
            UIBlockingProgressHUD.dismiss()
        }
    }
    
    func clearProfileUI() {
        for view in profileInformation {
            view.removeFromSuperview()
        }
        profileInformation.removeAll()
        
        self.nameLabel = nil
        self.loginName = nil
        self.descriptionLabel = nil
        self.avatarImage = nil
        
        self.skeleton.stopAllShimmerAnimations()
    }
    
    func switchToSplashRoot() {
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.rootViewController = SplashViewController()
                window.makeKeyAndVisible()
            }
        }
    }
    
    func showLoadingSkeleton() {
        view.layoutIfNeeded()
        
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            
            if let avatarImage, (avatarImage.image == nil || avatarImage.image == UIImage(resource: .emptyAvatar)) {
                self.skeleton.startShimmerAnimation(on: avatarImage, cornerRadius: 35)
            }
            if let nameLabel {
                self.skeleton.startShimmerAnimation(on: nameLabel, cornerRadius: 9)
            }
            if let loginName {
                self.skeleton.startShimmerAnimation(on: loginName, cornerRadius: 9)
            }
            if let descriptionLabel {
                self.skeleton.startShimmerAnimation(on: descriptionLabel, cornerRadius: 9)
            }
        }
    }
    
    func hideLoadingSkeleton() {
        if let nameLabel { skeleton.stopShimmerAnimation(on: nameLabel) }
        if let loginName { skeleton.stopShimmerAnimation(on: loginName) }
        if let descriptionLabel { skeleton.stopShimmerAnimation(on: descriptionLabel) }
    }
}
