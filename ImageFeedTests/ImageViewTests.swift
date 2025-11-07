import XCTest
@testable import ImageFeed

final class ImageViewTests: XCTestCase {
    
    var sut: ImagesListViewController!
    var presenterSpy: ImagesListPresenterSpy!
    
    override func setUp() {
        super.setUp()
        
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        sut = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        ) as? ImagesListViewController
        
        presenterSpy = ImagesListPresenterSpy()
        sut.configure(presenterSpy)
    }
    
    override func tearDown() {
        sut = nil
        presenterSpy = nil
        super.tearDown()
    }
    
    func testViewControllerCallsViewDidLoad() {
        //Given
        // инициализация сделана в SetUp
        
        //When
        sut.loadViewIfNeeded()
        
        //Then
        XCTAssertTrue(presenterSpy.viewDidLoadCalled)
    }
    
    func testViewControllerForwardsWillDisplayToPresenter() {
        //Given
        // инициализация сделана в SetUp
        
        //When
        sut.tableView(UITableView(), willDisplay: UITableViewCell(), forRowAt: IndexPath(row: 3, section: 0))
        
        //Then
        XCTAssertTrue(presenterSpy.willDisplayCalled)
        XCTAssertEqual(presenterSpy.receivedIndexPath, IndexPath(row:3, section: 0))
    }
    
    func testWillDisplayCellCallsFetchNextPageWhenLastCell() {
        //Given
        let imagesStub = ImagesListServiceStub()
        
        let presenter = ImagesListPresenter(imagesService: imagesStub)
        
        //When
        presenter.willDisplayCell(at: IndexPath(row: 2, section: 0))
        
        //Then
        XCTAssertEqual(imagesStub.fetchNextPageCallCount, 0)
        
        //When
        presenter.willDisplayCell(at: IndexPath(row: 4, section: 0))
        
        //Then
        XCTAssertEqual(imagesStub.fetchNextPageCallCount, 1)
        
    }
    
    func testHandlePhotosUpdateCallsSetPhotosAndInsertRows() {
        //Given
        let viewSpy = ImagesListViewControllerSpy()
        let imagesStub = ImagesListServiceStub()
        let presenter = ImagesListPresenter(imagesService: imagesStub)
        presenter.view = viewSpy
        
        //When
        presenter.viewDidLoad()
        
        NotificationCenter.default.post(
            name: type(of: imagesStub).didChangeNotification,
            object: imagesStub
        )
        
        //Then
        XCTAssertTrue(viewSpy.setPhotosCalled)
        XCTAssertTrue(viewSpy.insertRowsCalled)
    }
    
    func testHandlePhotosUpdateReloadsAllWhenCountDecreases() {
        //Given
        let imagesStub = ImagesListServiceStub()
        let viewSpy = ImagesListViewControllerSpy()
        let presenter = ImagesListPresenter(imagesService: imagesStub)
        presenter.view = viewSpy
        
        //When
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
        
        //Then
        XCTAssertTrue(viewSpy.reloadAllCalled, "При уменьшении фото должен вызываться reloadAll()")
        XCTAssertFalse(viewSpy.insertRowsCalled, "insertRows() не должен вызываться при уменьшении")
        XCTAssertTrue(viewSpy.setPhotosCalled, "setPhotos() должен быть вызван для обновления списка фото")
    }
    
    func testDidTapLikeSuccessUpdatesViewAndHidesHUD() {
        //Given
        let imagesStub = ImagesListServiceStub()
        let viewSpy = ImagesListViewControllerSpy()
        let presenter = ImagesListPresenter(imagesService: imagesStub)
        presenter.view = viewSpy
        
        //When
        presenter.didTapLike(at: IndexPath(row: 0, section: 0))
        
        let exp = expectation(description: "like success handled")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { exp.fulfill() }
        wait(for: [exp], timeout: 1.0)
        
        //Then
        XCTAssertEqual(viewSpy.hudCalls, [true, false])
        XCTAssertEqual(viewSpy.setPhotosCallCount, 1)
        XCTAssertEqual(viewSpy.updatedLikes.count, 1)
        XCTAssertEqual(viewSpy.updatedLikes.first?.0, IndexPath(row: 0, section: 0))
        XCTAssertEqual(viewSpy.updatedLikes.first?.1, true)
    }
    
    func testDidTapLikeFailureShowsErrorAndHidesHUD() {
        //Given
        let imagesStub = ImagesListServiceStub()
        imagesStub.shouldFailChangeLike = true

        let viewSpy = ImagesListViewControllerSpy()
        let presenter = ImagesListPresenter(imagesService: imagesStub)
        presenter.view = viewSpy
        
        //When
        presenter.didTapLike(at: IndexPath(row: 0, section: 0))
        
        let exp = expectation(description: "like failure handled")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { exp.fulfill() }
        wait(for: [exp], timeout: 1.0)
        
        //Then
        XCTAssertEqual(viewSpy.hudCalls, [true, false], "HUD должен быть показан и скрыт")
        XCTAssertTrue(viewSpy.showErrorCalled, "При ошибке должен показываться алерт с ошибкой")
        XCTAssertEqual(viewSpy.updatedLikes.count, 0, "Лайк не должен обновляться при ошибке")
        XCTAssertEqual(viewSpy.setPhotosCallCount, 0, "setPhotos не должен вызываться при ошибке")
    }
    
    func testDateFormatterFormatsDateAndHandlesNil() {
        // Given
        let helper = ImagesListDateFormatter()
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!

        let components = DateComponents(year: 2025, month: 10, day: 27, hour: 12, minute: 34)
        let date = calendar.date(from: components)!
        
        // When
        let formatted = helper.text(from: date)
        let nilFormatted = helper.text(from: nil)
        
        // Then
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
