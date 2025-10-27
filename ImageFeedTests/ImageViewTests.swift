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
    
    func testDidTapLikeSuccessUpdatesViewAndHidesHUD() {
        //given
        let imagesStub = ImagesListServiceStub()
        let viewSpy = ImagesListViewControllerSpy()
        let presenter = ImagesListPresenter(imagesService: imagesStub)
        presenter.view = viewSpy
        
        //when
        presenter.didTapLike(at: IndexPath(row: 0, section: 0))
        
        let exp = expectation(description: "like success handled")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { exp.fulfill() }
        wait(for: [exp], timeout: 1.0)
        
        //then
        XCTAssertEqual(viewSpy.hudCalls, [true, false])
        XCTAssertEqual(viewSpy.setPhotosCallCount, 1)
        XCTAssertEqual(viewSpy.updatedLikes.count, 1)
        XCTAssertEqual(viewSpy.updatedLikes.first?.0, IndexPath(row: 0, section: 0))
        XCTAssertEqual(viewSpy.updatedLikes.first?.1, true)
    }
    
    func testDidTapLikeFailureShowsErrorAndHidesHUD() {
        //given
        let imagesStub = ImagesListServiceStub()
        imagesStub.shouldFailChangeLike = true

        let viewSpy = ImagesListViewControllerSpy()
        let presenter = ImagesListPresenter(imagesService: imagesStub)
        presenter.view = viewSpy
        
        //when
        presenter.didTapLike(at: IndexPath(row: 0, section: 0))
        
        let exp = expectation(description: "like failure handled")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { exp.fulfill() }
        wait(for: [exp], timeout: 1.0)
        
        //then
        XCTAssertEqual(viewSpy.hudCalls, [true, false], "HUD должен быть показан и скрыт")
        XCTAssertTrue(viewSpy.showErrorCalled, "При ошибке должен показываться алерт с ошибкой")
        XCTAssertEqual(viewSpy.updatedLikes.count, 0, "Лайк не должен обновляться при ошибке")
        XCTAssertEqual(viewSpy.setPhotosCallCount, 0, "setPhotos не должен вызываться при ошибке")
    }
    
    func testDateFormatterFormatsDateAndHandlesNil() {
        // given
        let helper = ImagesListDateFormatter()
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!

        let components = DateComponents(year: 2025, month: 10, day: 27, hour: 12, minute: 34)
        let date = calendar.date(from: components)!
        
        // when
        let formatted = helper.text(from: date)
        let nilFormatted = helper.text(from: nil)
        
        // then
        XCTAssertNotNil(formatted, "Форматтер должен возвращать строку для валидной даты")
        XCTAssertTrue(formatted.contains("27"), "Формат должен содержать день месяца")
        XCTAssertTrue(formatted.contains("2025"), "Формат должен содержать год")
        
        let lower = formatted.lowercased()
        XCTAssertTrue(lower.contains("окт") || lower.contains("oct"),
                      "Формат должен содержать месяц")
        XCTAssertTrue(nilFormatted.isEmpty || nilFormatted == "—",
                      "При nil форматтер должен возвращать пустую строку или плейсхолдер")
    }
}

class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
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
    var shouldFailChangeLike = false
    enum StubError: Error { case likeFailed }
    
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
        
        if shouldFailChangeLike {
            return DispatchQueue.main.async {
                completion(.failure(StubError.likeFailed))
            }
        }
        
        if let index = photos.firstIndex(where: { $0.id == photoId }) {
            
            var updatedPhoto = photos[index]
            
            updatedPhoto = Photo(
                id: updatedPhoto.id,
                size: updatedPhoto.size,
                createdAt: updatedPhoto.createdAt,
                welcomeDescription: updatedPhoto.welcomeDescription,
                thumbImageURL: updatedPhoto.thumbImageURL,
                largeImageURL: updatedPhoto.largeImageURL,
                fullImageURL: updatedPhoto.fullImageURL,
                isLiked: isLike
            )
            
            photos[index] = updatedPhoto
        }
        
        DispatchQueue.main.async {
            completion(.success(()))
        }
    }
}
