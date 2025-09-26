import UIKit

final class ProfileViewController: UIViewController {
    private var nameLabel: UILabel?
    private var loginName: UILabel?
    private var descriptionLabel: UILabel?
    private var avatarImage: UIImageView?
    private var logoutButton: UIButton?
    private var profileInformation: [UIView] = []
    private let profileService = ProfileService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addViewsToScreen()
        
        guard let token = OAuth2TokenStorage.shared.token else {
            print("Error: missing OAuth token")
            return
        }
        
        profileService.fetchProfile(token) { [weak self] result in
                guard let self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let profile):
                    self.updateProfileDetails(with: profile)
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
        }
    }
    
    private func updateProfileDetails(with profile: Profile) {
        nameLabel?.text = profile.name.isEmpty ? "Имя не указано"
        : profile.name
        loginName?.text = profile.loginName.isEmpty ? "@неизвестный_пользователь"
        : profile.loginName
        descriptionLabel?.text = (profile.bio?.isEmpty ?? true)
        ? "Профиль не заполнен"
        : profile.bio
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
        
        nameLabel.text = "Екатерина Новикова"
        nameLabel.textColor = UIColor(named: "YP White")
        nameLabel.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        
        loginName.text = "@ekaterina_nov"
        loginName.textColor = UIColor(named: "YP Gray")
        loginName.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        
        descriptionLabel.text = "Hello, world!"
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
        
        for view in profileInformation {
            view.removeFromSuperview()
        }
        profileInformation.removeAll()
        
        nameLabel = nil
        loginName = nil
        descriptionLabel = nil
        avatarImage = nil
        
        let emptyAvatar = UIImageView(image: UIImage(named: "emptyAvatar"))
        emptyAvatar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyAvatar)
        guard let logoutButton = self.logoutButton else { return }
        
        NSLayoutConstraint.activate([
            emptyAvatar.widthAnchor.constraint(equalToConstant: 70),
            emptyAvatar.heightAnchor.constraint(equalToConstant: 70),
            emptyAvatar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            emptyAvatar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            
            logoutButton.centerYAnchor.constraint(equalTo: emptyAvatar.centerYAnchor)
            ])
    }
}
