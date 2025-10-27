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
