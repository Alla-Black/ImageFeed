import XCTest
@testable import ImageFeed

final class ImageViewTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        //given
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let sut = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        ) as! ImagesListViewController
        
        let presenterSpy = ImagesListPresenterSpy()
        sut.configure(presenterSpy)
        
        //when
        sut.loadViewIfNeeded()
        
        //then
        XCTAssertTrue(presenterSpy.viewDidLoadCalled)
    }
    
    func testViewControllerForwardsWillDisplayToPresenter() {
        //given
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let sut = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        ) as! ImagesListViewController
        
        let presenterSpy = ImagesListPresenterSpy()
        sut.configure(presenterSpy)
        
        //when
        sut.tableView(UITableView(), willDisplay: UITableViewCell(), forRowAt: IndexPath(row: 3, section: 0))
        
        //then
        XCTAssertTrue(presenterSpy.willDisplayCalled)
        XCTAssertEqual(presenterSpy.receivedIndexPath, IndexPath(row:3, section: 0))
    }
    
    func testWillDisplayCellCallsFetchNextPageWhenLastCell() {
        //given
        let imagesStub = ImagesListServiceStub()
        
        let presenter = ImagesListPresenter(imagesService: imagesStub)
        
        //when
        presenter.willDisplayCell(at: IndexPath(row: 2, section: 0))
        
        //then
        XCTAssertEqual(imagesStub.fetchNextPageCallCount, 0)
        
        //when
        presenter.willDisplayCell(at: IndexPath(row: 4, section: 0))
        
        //then
        XCTAssertEqual(imagesStub.fetchNextPageCallCount, 1)
        
    }
    
    func testHandlePhotosUpdateCallsSetPhotosAndInsertRows() {
        //given
        let viewSpy = ImagesListViewControllerSpy()
        let imagesStub = ImagesListServiceStub()
        let presenter = ImagesListPresenter(imagesService: imagesStub)
        presenter.view = viewSpy
        
        //when
        presenter.viewDidLoad()
        
        NotificationCenter.default.post(
            name: type(of: imagesStub).didChangeNotification,
            object: imagesStub
        )
        
        //then
        XCTAssertTrue(viewSpy.setPhotosCalled)
        XCTAssertTrue(viewSpy.insertRowsCalled)
    }
    
    func testHandlePhotosUpdateReloadsAllWhenCountDecreases() {
        //given
        let imagesStub = ImagesListServiceStub()
        let viewSpy = ImagesListViewControllerSpy()
        let presenter = ImagesListPresenter(imagesService: imagesStub)
        presenter.view = viewSpy
        
        //when
        presenter.viewDidLoad()
        NotificationCenter.default.post(
            name: type(of: imagesStub).didChangeNotification,
            object: imagesStub
        )
        
        let firstExp = expectation(description: "first notification handled")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            firstExp.fulfill()
        }
        wait(for: [firstExp], timeout: 1.0)
        
        viewSpy.setPhotosCalled = false
        viewSpy.insertRowsCalled = false
        viewSpy.reloadAllCalled = false
        
        imagesStub.photos = Array(imagesStub.photos.prefix(3))
        
        NotificationCenter.default.post(
            name: type(of: imagesStub).didChangeNotification,
            object: imagesStub)
        
        let secondExp = expectation(description: "second notification handled")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            secondExp.fulfill()
        }
        wait(for: [secondExp], timeout: 1.0)
        
        //then
        XCTAssertTrue(viewSpy.reloadAllCalled, "При уменьшении фото должен вызываться reloadAll()")
        XCTAssertFalse(viewSpy.insertRowsCalled, "insertRows() не должен вызываться при уменьшении")
        XCTAssertTrue(viewSpy.setPhotosCalled, "setPhotos() должен быть вызван для обновления списка фото")
    }
}

class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    var presenter: ImagesListPresenterProtocol?
    var setPhotosCalled: Bool = false
    var insertRowsCalled: Bool = false
    var reloadAllCalled: Bool = false
    
    func insertRows(at indexPaths: [IndexPath]) {
        insertRowsCalled = true
    }
    
    func reloadAll() {
        reloadAllCalled = true
    }
    
    func showError(message: String) {
        
    }
    
    func showBlockingHUD(_ show: Bool) {
        
    }
    
    func updateLike(at indexPath: IndexPath, isLiked: Bool) {
        
    }
    
    func setPhotos(_ photos: [Photo]) {
        setPhotosCalled = true
    }
}

class ImagesListPresenterSpy: ImagesListPresenterProtocol {
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

class ImagesListServiceStub: ImagesListServiceProtocol {
    var photos: [Photo] = [
        Photo(id: "1",
              size: CGSize(width: 100, height: 100),
              createdAt: Date(),
              welcomeDescription: nil,
              thumbImageURL: "",
              largeImageURL: "",
              fullImageURL: "",
              isLiked: false),
        
        Photo(id: "2",
              size: CGSize(width: 100, height: 100),
              createdAt: Date(),
              welcomeDescription: nil,
              thumbImageURL: "",
              largeImageURL: "",
              fullImageURL: "",
              isLiked: false),
        
        Photo(id: "3",
              size: CGSize(width: 100, height: 100),
              createdAt: Date(),
              welcomeDescription: nil,
              thumbImageURL: "",
              largeImageURL: "",
              fullImageURL: "",
              isLiked: false),
        
        Photo(id: "4",
              size: CGSize(width: 100, height: 100),
              createdAt: Date(),
              welcomeDescription: nil,
              thumbImageURL: "",
              largeImageURL: "",
              fullImageURL: "",
              isLiked: false),
        
        Photo(id: "5",
              size: CGSize(width: 100, height: 100),
              createdAt: Date(),
              welcomeDescription: nil,
              thumbImageURL: "",
              largeImageURL: "",
              fullImageURL: "",
              isLiked: false)
    ]
    
    static var didChangeNotification = Notification.Name("ImagesListServiceStub.didChange")
    var fetchNextPageCallCount = 0
    
    func fetchPhotosNextPage() {
        fetchNextPageCallCount += 1
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        
    }
}
