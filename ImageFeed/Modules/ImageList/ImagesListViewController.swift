import UIKit
import Kingfisher

// MARK: - ImagesListViewControllerProtocol
protocol ImagesListViewControllerProtocol: AnyObject {
    var presenter: ImagesListPresenterProtocol? { get set }
    
    func insertRows(at indexPaths: [IndexPath])
    func reloadAll()
    func showError(message: String)
    func showBlockingHUD(_ show: Bool)
    func updateLike(at indexPath: IndexPath, isLiked: Bool)
    func setPhotos(_ photos: [Photo])
}

// MARK: - ImagesListViewController
final class ImagesListViewController: UIViewController {
    
    // MARK: - IB Outlets
    @IBOutlet private var tableView: UITableView!
    
    // MARK: - Public Properties
    var photos: [Photo] = []
    
    var presenter: ImagesListPresenterProtocol?
    
    // MARK: - Private Properties
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    
    private let dateFormatterHelper: ImagesListDateFormatterProtocol = ImagesListDateFormatter()
    
    private var skeleton = SkeletonAnimationService()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter?.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        // Настройки внешнего вида Tab Bar — ДЕЛАЮТ ЕГО ЧЁРНЫМ
        if let tabBar = tabBarController?.tabBar {
            if #available(iOS 13.0, *) {
                let appearance = UITabBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = UIColor(resource: .ypBlack)
                tabBar.standardAppearance = appearance
                if #available(iOS 15.0, *) {
                    tabBar.scrollEdgeAppearance = appearance
                }
            } else {
                tabBar.barTintColor = UIColor(resource: .ypBlack)
            }
            tabBar.tintColor = .white // Цвет активной иконки/tab label
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Invalid segue destination")
                return
            }
            
            let photo = photos[indexPath.row]
            viewController.fullImageURL = URL(string: photo.fullImageURL)
            
            if let cell = tableView.cellForRow(at: indexPath) as?ImagesListCell {
                viewController.image = cell.imageInCell.image
            } else {
                viewController.image = nil
            }
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    // MARK: - Public Methods
    func configure(_ presenter: ImagesListPresenterProtocol) {
        self.presenter = presenter
        presenter.view = self
    }
}

// MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let photo = photos[indexPath.row]
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = photo.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        
        return cellHeight
    }
    
    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        presenter?.willDisplayCell(at: indexPath)
    }
}

// MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        imageListCell.delegate = self
        
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
}

// MARK: - ImagesListViewController + Configuration
extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        
        let photo = photos[indexPath.row]
        
        cell.dataLabel.text = dateFormatterHelper.text(from: photo.createdAt)
        
        cell.setIsLiked(photo.isLiked)
        
        cell.imageInCell.kf.indicatorType = .activity
        
        let placeholder = UIImage(resource: .placeholder)
        
        self.skeleton.startShimmerAnimation(on: cell.imageInCell, cornerRadius: 16)
        
        if let url = URL(string: photo.thumbImageURL) {
            cell.imageInCell.kf.setImage(with: url, placeholder: placeholder) { [weak self, weak cell] _ in
                guard
                    let self,
                    let cell = cell
                else { return }
                self.skeleton.stopShimmerAnimation(on: cell.imageInCell)
            }
        } else {
            cell.imageInCell.image = placeholder
            self.skeleton.stopShimmerAnimation(on: cell.imageInCell)
        }
    }
}

//MARK: - ImagesListCellDelegate
extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        presenter?.didTapLike(at: indexPath)
    }
}

//MARK: - ImagesListViewControllerProtocol
extension ImagesListViewController: ImagesListViewControllerProtocol {
    
    func insertRows(at indexPaths: [IndexPath]) {
        tableView.performBatchUpdates {
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
    
    func reloadAll() {
        tableView.reloadData()
    }
    
    func showError(message: String) {
        let alert = UIAlertController(
            title: "Что-то пошло не так(",
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
    
    func showBlockingHUD(_ show: Bool) {
        if show { UIBlockingProgressHUD.show() } else { UIBlockingProgressHUD.dismiss() }
    }
    
    func updateLike(at indexPath: IndexPath, isLiked: Bool) {
        if let cell = tableView.cellForRow(at: indexPath) as? ImagesListCell { cell.setIsLiked(isLiked) }
    }
    
    func setPhotos(_ photos: [Photo]) {
        self.photos = photos
    }
}
