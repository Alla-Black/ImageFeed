import Foundation
import UIKit

final class ProfileViewController: UIViewController {
    @IBOutlet private weak var avatarImage: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var loginName: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    
    @IBOutlet private weak var logoutButton: UIButton!
    
    @IBAction func didTapLogoutButton() {
    }
}
