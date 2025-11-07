import XCTest
@testable import ImageFeed

final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    var presenter: ImagesListPresenterProtocol?
    var setPhotosCalled: Bool = false
    var insertRowsCalled: Bool = false
    var reloadAllCalled: Bool = false
    var hudCalls: [Bool] = []
    var setPhotosCallCount = 0
    var updatedLikes: [(IndexPath, Bool)] = []
    var showErrorCalled = false
    
    func insertRows(at indexPaths: [IndexPath]) {
        insertRowsCalled = true
    }
    
    func reloadAll() {
        reloadAllCalled = true
    }
    
    func showError(message: String) {
        showErrorCalled = true
    }
    
    func showBlockingHUD(_ show: Bool) {
        hudCalls.append(show)
    }
    
    func updateLike(at indexPath: IndexPath, isLiked: Bool) {
        updatedLikes.append((indexPath, isLiked))
    }
    
    func setPhotos(_ photos: [Photo]) {
        setPhotosCalled = true
        setPhotosCallCount += 1
    }
}
