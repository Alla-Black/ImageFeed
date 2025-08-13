import Foundation
import UIKit

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet weak var imageInCell: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dataLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        dataLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        dataLabel.textColor = UIColor(named: "YP White")
        
        likeButton.setImage(UIImage(named: "like_button_off"), for: .normal)
        likeButton.setImage(UIImage(named: "like_button_on"), for: .selected) 
    }
}
