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
}

class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    var view: ImagesListViewControllerProtocol?
    var viewDidLoadCalled: Bool = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func willDisplayCell(at indexPath: IndexPath) {
        
    }
    
    func didTapLike(at indexPath: IndexPath) {
        
    }
}
