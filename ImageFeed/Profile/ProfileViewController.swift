import UIKit
import Kingfisher
import ProgressHUD

final class ProfileViewController: UIViewController {
    private var nameLabel: UILabel?
    private var loginName: UILabel?
    private var descriptionLabel: UILabel?
    private var avatarImage: UIImageView?
    private var logoutButton: UIButton?
    private var profileInformation: [UIView] = []
    
    private var profileImageServiceObserver: NSObjectProtocol?
    
    private let skeleton = SkeletonAnimationService()
    private var didStartSkeleton = false
    private var isProfileDetailsLoaded = false
    
    private var nameW: NSLayoutConstraint?
    private var loginW: NSLayoutConstraint?
    private var descriptionW: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(named: "YP Black")
        
        addViewsToScreen()
        
        if let profile = ProfileService.profileService.profile {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.updateProfileDetails(with: profile)
            }
        }
        
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            self.updateAvatar()
        }
        updateAvatar()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard !didStartSkeleton else { return }
        didStartSkeleton = true
        
        if let avatarImage, (avatarImage.image == nil || avatarImage.image == UIImage(resource: .emptyAvatar)) {
            skeleton.startShimmerAnimation(on: avatarImage, cornerRadius: 35)
        }
        if let nameLabel {
            skeleton.startShimmerAnimation(on: nameLabel, cornerRadius: 9)
        }
        if let loginName {
            skeleton.startShimmerAnimation(on: loginName, cornerRadius: 9)
        }
        if let descriptionLabel {
            skeleton.startShimmerAnimation(on: descriptionLabel, cornerRadius: 9)
        }
    }
    
    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else {
            avatarImage?.kf.cancelDownloadTask()
            avatarImage?.image = UIImage(resource: .emptyAvatar)
            if let avatarImage { skeleton.stopShimmerAnimation(on: avatarImage) }
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
            switch result {
            case .success(let value):
                print(value.image)
                print(value.cacheType)
                print(value.source)
                
            case .failure(let error):
                print(error)
            }
            
            if let avatar = self?.avatarImage {
                self?.skeleton.stopShimmerAnimation(on: avatar)
            }
        }
    }

    private func updateProfileDetails(with profile: Profile) {
        nameLabel?.text = profile.name.isEmpty ? "Имя не указано" : profile.name
        if let nameLabel {
            skeleton.stopShimmerAnimation(on: nameLabel)
        }
        
        loginName?.text = profile.loginName.isEmpty ? "@неизвестный_пользователь" : profile.loginName
        if let loginName { skeleton.stopShimmerAnimation(on: loginName)
        }
        
        descriptionLabel?.text = (profile.bio?.isEmpty ?? true)
        ? "Профиль не заполнен" : profile.bio
        if let descriptionLabel { skeleton.stopShimmerAnimation(on: descriptionLabel)
        }
        isProfileDetailsLoaded = true
        
        [nameW, loginW, descriptionW].forEach { $0?.isActive = false }
    }
    private func addViewsToScreen() {
        let avatarImage = UIImageView(image: UIImage(named: "photoProfile"))
        
        let nameLabel = UILabel()
        let loginName = UILabel()
        let descriptionLabel = UILabel()
        let logoutButton = UIButton.systemButton(
            with: UIImage(named: "exitButton")!,
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
        nameLabel.textColor = UIColor(named: "YP White")
        nameLabel.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        
        loginName.text = ""
        loginName.textColor = UIColor(named: "YP Gray")
        loginName.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        
        descriptionLabel.text = ""
        descriptionLabel.textColor = UIColor(named: "YP White")
        descriptionLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        
        logoutButton.tintColor = UIColor(named: "YP Red")
        
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
    
    @objc func didTapLogoutButton () {
        
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert
        )
        let logoutAction = UIAlertAction(title: "Да", style: .default) { [weak self] _ in
            guard let self else { return }
            
            UIBlockingProgressHUD.show()
            
            ProfileLogoutService.shared.logout()
            
            for view in profileInformation {
                view.removeFromSuperview()
            }
            profileInformation.removeAll()
            
            self.nameLabel = nil
            self.loginName = nil
            self.descriptionLabel = nil
            self.avatarImage = nil
            
            self.skeleton.stopAllShimmerAnimations()
            
            UIBlockingProgressHUD.dismiss()
            
            self.switchToSplashRoot()
            }
        
        let cancelAction = UIAlertAction(title: "Нет", style: .default)
        
        alert.addAction(logoutAction)
        alert.addAction(cancelAction)
            
        present(alert, animated: true)
    }
    
    private func switchToSplashRoot() {
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.rootViewController = SplashViewController()
                window.makeKeyAndVisible()
            }
        }
    }
    
    deinit {
        if let observer = profileImageServiceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
