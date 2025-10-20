import UIKit

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    weak var delegate: ImagesListCellDelegate?
    
    @IBOutlet weak var imageInCell: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dataLabel: UILabel!
    @IBOutlet weak var gradientView: UIView!
    
    private let gradientLayer = CAGradientLayer()
    
    private let skeleton = SkeletonAnimationService()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        dataLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        dataLabel.textColor = UIColor(resource: .ypWhite)
        
        likeButton.setImage(UIImage(resource: .likeButtonOff), for: .normal)
        likeButton.setImage(UIImage(resource: .likeButtonOn), for: .selected)
        
        gradientView.layer.cornerRadius = imageInCell.layer.cornerRadius
        gradientView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        let topColor = UIColor(resource: .ypBlack).withAlphaComponent(0.0).cgColor
        let bottomColor = UIColor(resource: .ypBlack).withAlphaComponent(1.0).cgColor
        
        gradientLayer.colors = [topColor, bottomColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.locations = [0.0, 1.0]
        
        gradientView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = gradientView.bounds
        gradientView.layer.cornerRadius = imageInCell.layer.cornerRadius
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        skeleton.stopAllShimmerAnimations()
        
        imageInCell.kf.cancelDownloadTask()
        
        imageInCell.image = UIImage(resource: .placeholder)
        dataLabel.text = nil
        likeButton.isSelected = false
        
        skeleton.startShimmerAnimation(on: imageInCell, cornerRadius: 16)
    }
    
    @IBAction private func likeButtonClicked() {
        delegate?.imageListCellDidTapLike(self)
    }
    
    func setIsLiked(_ isLiked: Bool) {
        likeButton.isSelected = isLiked
        likeButton.accessibilityValue = isLiked ? "liked" : "not liked"
    }
}

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}
