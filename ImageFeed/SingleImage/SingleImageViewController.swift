import UIKit
import Kingfisher

final class SingleImageViewController: UIViewController {
    var image: UIImage? {
        didSet {
            guard let image, isViewLoaded else { return }
            imageView.image = image
            
            rescaleAndCenterImageInScrollView(image: image)
        }
    }
    
    var fullImageURL: URL?
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var shareButton: UIButton!
    
    @IBAction func didTapBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapShareButton(_ sender: Any) {
        guard let image else { return }
        let share = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(share, animated: true, completion: nil)
        
        share.overrideUserInterfaceStyle = .dark
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backButton.accessibilityIdentifier = "backButton"
        
        scrollView.delegate = self
        
        if fullImageURL != nil {
                loadImage()
        } else {
            guard let image else { return }
            imageView.image = image
            imageView.frame.size = image.size
        
            rescaleAndCenterImageInScrollView(image: image)
        }
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, max(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
    
    private func loadImage() {
        UIBlockingProgressHUD.show()
        
        imageView.kf.setImage(with: fullImageURL) { [weak self] result in
            
            UIBlockingProgressHUD.dismiss()
            
            guard let self else { return }
            
            switch result {
            case .success(let value):
                self.imageView.frame.size = value.image.size
                self.rescaleAndCenterImageInScrollView(image: value.image)
            case .failure:
                self.showError()
            }
        }
    }
    
    private func showError() {
        let alert = UIAlertController(
            title: "Что-то пошло не так(",
            message: "Попробовать еще раз?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Не надо", style: .cancel))
        alert.addAction(UIAlertAction(title: "Повторить", style: .default, handler: { [weak self] _ in
            self?.loadImage()
        }))
        self.present(alert, animated: true)
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
}
