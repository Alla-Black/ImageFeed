import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    @IBOutlet private var tableView: UITableView!
    
    var photos: [Photo] = []
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
    
    private let imagesListService = ImagesListService.shared
    private var imagesListServiceObserver: NSObjectProtocol?
    
    private var skeleton = SkeletonAnimationService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        // Настройки внешнего вида Tab Bar — ДЕЛАЮТ ЕГО ЧЁРНЫМ
        if let tabBar = tabBarController?.tabBar {
            if #available(iOS 13.0, *) {
                let appearance = UITabBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = UIColor(named: "YP Black") ?? .black
                tabBar.standardAppearance = appearance
                if #available(iOS 15.0, *) {
                    tabBar.scrollEdgeAppearance = appearance
                }
            } else {
                tabBar.barTintColor = UIColor(named: "YP Black") ?? .black
            }
            tabBar.tintColor = .white // Цвет активной иконки/tab label
        }
        
        imagesListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: imagesListService,
            queue: .main
        ) { [weak self] _ in
            self?.updateTableViewAnimated()
        }

        imagesListService.fetchPhotosNextPage()
    }
    
    deinit {
        if let observer = imagesListServiceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
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
}

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
        if indexPath.row + 1 == photos.count {
            imagesListService.fetchPhotosNextPage()
        }
    }
}

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

extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        
        let photo = photos[indexPath.row]
        
        if let date = photo.createdAt {
            cell.dataLabel.text = dateFormatter.string(from: date)
        } else {
            cell.dataLabel.text = ""
        }
        
        cell.setIsLiked(photo.isLiked)
        
        cell.imageInCell.kf.indicatorType = .activity
        
        let placeholder = UIImage(named: "placeholder")
        
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
    
    func updateTableViewAnimated() {
        let oldCount = photos.count
        let newPhotos = imagesListService.photos
        let newCount = newPhotos.count
        
        guard oldCount != newCount else { return }
        
        if newCount > oldCount {
            
            photos = newPhotos
            let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
            tableView.performBatchUpdates {
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        } else {
            
            photos = newPhotos
            tableView.reloadData()
        }
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        
        UIBlockingProgressHUD.show()
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success:
                self.photos = self.imagesListService.photos
                cell.setIsLiked(self.photos[indexPath.row].isLiked)
                
                UIBlockingProgressHUD.dismiss()
                
            case .failure(let error):
                UIBlockingProgressHUD.dismiss()
                
                let alert = UIAlertController(
                    title: "Что-то пошло не так(",
                    message: error.localizedDescription,
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
        }
    }
}
