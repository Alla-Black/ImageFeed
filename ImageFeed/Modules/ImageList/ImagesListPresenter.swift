import Foundation

// MARK: - ImagesListPresenterProtocol

protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListViewControllerProtocol? { get set }
    
    func viewDidLoad()
    func willDisplayCell(at indexPath: IndexPath)
    func didTapLike(at indexPath: IndexPath)
}

// MARK: - ImagesListPresenter

final class ImagesListPresenter {
    
    // MARK: - Public Properties
    
    weak var view: ImagesListViewControllerProtocol?
    
    // MARK: - Private Properties
    
    private var lastCount = 0
    
    private var imagesObserver: NSObjectProtocol?
    private var imagesService: ImagesListServiceProtocol
    
    private let isUITesting = ProcessInfo.processInfo.arguments.contains("-uiTesting")
    
    // MARK: - Initializers
    
    init(imagesService: ImagesListServiceProtocol = ImagesListService.shared) {
        self.imagesService = imagesService
    }
    
    // MARK: - Private Methods
    
    private func handlePhotosUpdate() {
        let newPhotos = imagesService.photos
        let old = lastCount
        let new = newPhotos.count
        guard new != old else { return }
        
        view?.setPhotos(newPhotos)
        
        if new > old {
            let indexPaths = (old..<new).map { IndexPath(row: $0, section: 0) }
            view?.insertRows(at: indexPaths)
        } else {
            view?.reloadAll()
        }
        
        lastCount = new
    }
    
    // MARK: - Deinitialization
    
    deinit {
        if let token = imagesObserver {
            NotificationCenter.default.removeObserver(token)
        }
    }
}

// MARK: - ImagesListPresenterProtocol

extension ImagesListPresenter: ImagesListPresenterProtocol {
    func viewDidLoad() {
        imagesObserver = NotificationCenter.default.addObserver(
            forName: type(of: imagesService).didChangeNotification,
            object: imagesService,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            
            self.handlePhotosUpdate()
        }
        
        imagesService.fetchPhotosNextPage()
    }
    
    func willDisplayCell(at indexPath: IndexPath) {
        if isUITesting { return }
        
        let count = imagesService.photos.count
        if indexPath.row + 1 == count {
            imagesService.fetchPhotosNextPage()
        }
    }
    
    func didTapLike(at indexPath: IndexPath) {
        let photos = imagesService.photos
        let current = photos[indexPath.row].isLiked
        let newState = !current
        
        view?.showBlockingHUD(true)
        
        imagesService.changeLike(photoId: photos[indexPath.row].id, isLike: newState) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success:
                let updated = imagesService.photos
                view?.setPhotos(updated)
                
                view?.updateLike(at: indexPath, isLiked: updated[indexPath.row].isLiked)
                
                view?.showBlockingHUD(false)
                
            case .failure(let error):
                view?.showBlockingHUD(false)
                
                view?.showError(message: error.localizedDescription)
            }
        }
    }
}
