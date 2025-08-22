import Foundation
import UIKit

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet weak var imageInCell: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dataLabel: UILabel!
    @IBOutlet weak var gradientView: UIView!
    
    private let gradientLayer = CAGradientLayer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        dataLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        dataLabel.textColor = UIColor(named: "YP White")
        
        likeButton.setImage(UIImage(named: "like_button_off"), for: .normal)
        likeButton.setImage(UIImage(named: "like_button_on"), for: .selected)
        
        gradientView.layer.cornerRadius = imageInCell.layer.cornerRadius
        gradientView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        let topColor = UIColor(named: "YP Black")!.withAlphaComponent(0.0).cgColor
        let bottomColor = UIColor(named: "YP Black")!.withAlphaComponent(1.0).cgColor
        
        gradientLayer.colors = [topColor, bottomColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.locations = [0.0, 1.0]
        
        gradientView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = gradientView.bounds
    }
    
}
