import XCTest
@testable import ImageFeed

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    var view: ImagesListViewControllerProtocol?
    var viewDidLoadCalled: Bool = false
    var willDisplayCalled = false
    var receivedIndexPath: IndexPath?
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func willDisplayCell(at indexPath: IndexPath) {
        willDisplayCalled = true
        receivedIndexPath = indexPath
    }
    
    func didTapLike(at indexPath: IndexPath) {
        
    }
}
