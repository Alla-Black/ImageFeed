import UIKit

final class SkeletonAnimationService {
    
    // MARK: - Private Properties
    
    private var animationLayers = Set<CALayer>()
    private let shimmerLayerName = "shimmerLayer"
    
    // MARK: - Public Methods
    
    func startShimmerAnimation(on view: UIView, cornerRadius: CGFloat, explicitSize: CGSize? = nil) {
        view.layoutIfNeeded()
        
        let size = explicitSize ?? view.bounds.size
        guard size.width > 0, size.height > 0 else { return }
        
        let gradient = CAGradientLayer()
        gradient.name = shimmerLayerName
        gradient.frame = CGRect(origin: .zero, size: size)
        gradient.locations = [0, 0.1, 0.3]
        gradient.colors = [
            UIColor(red: 174/255, green: 175/255, blue: 180/255, alpha: 1).cgColor,
            UIColor(red: 174/255, green: 175/255, blue: 180/255, alpha: 0.3).cgColor,
            UIColor(red: 174/255, green: 175/255, blue: 180/255, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.cornerRadius = cornerRadius
        gradient.masksToBounds = true
        
        let animate = CABasicAnimation()
        animate.keyPath = "locations"
        animate.duration = 1
        animate.repeatCount = .infinity
        animate.fromValue = [0, 0.1, 0.3]
        animate.toValue = [0, 0.8, 1]
        gradient.add(animate, forKey: "locationsChange")
        
        view.layer.addSublayer(gradient)
        animationLayers.insert(gradient)
    }
    
    func stopShimmerAnimation(on view: UIView) {
        view.layer.sublayers?
            .filter { $0.name == shimmerLayerName }
            .forEach { layer in
                layer.removeAllAnimations()
                layer.removeFromSuperlayer()
                animationLayers.remove(layer)
            }
    }
    
    func stopAllShimmerAnimations() {
        animationLayers.forEach {
            $0.removeAllAnimations()
            $0.removeFromSuperlayer()
        }
        animationLayers.removeAll()
    }
}
