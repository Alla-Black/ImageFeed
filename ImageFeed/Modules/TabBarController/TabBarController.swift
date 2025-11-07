import UIKit

final class TabBarController: UITabBarController {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
        guard let imagesListViewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as? ImagesListViewController else {
            assertionFailure("ImagesListViewController not found in Main.storyboard")
            return
        }
        let imagesPresenter = ImagesListPresenter()
        imagesListViewController.configure(imagesPresenter)
        imagesListViewController.tabBarItem = UITabBarItem(
                title: "",
                image: UIImage(resource: .tabEditorialActive),
                selectedImage: nil
            )
        let imagesNavigationController = UINavigationController(rootViewController: imagesListViewController)
        imagesNavigationController.setNavigationBarHidden(true, animated: false)
        
        let profileViewController = ProfileViewController()
        let profilePresenter = ProfilePresenter()
        
        profileViewController.configure(profilePresenter)
        
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(resource: .tabProfileActive),
            selectedImage: nil
        )
        
        viewControllers = [imagesNavigationController, profileViewController]
    }
}
