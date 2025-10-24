import Testing
import ImageFeed
import Foundation
@testable import ImageFeed
import XCTest

final class WebViewTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        //given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "WebViewViewController") as! WebViewViewController
        let presenter = WebViewPresenterSpy()
        
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        _ = viewController.view
        
        //then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testPresenterCallsLoadRequest() {
        //given
        let helper = AuthHelperStub()
        let presenter = WebViewPresenter(authHelper: helper)
        
        let webViewSpy = WebViewViewControllerSpy()
        presenter.view = webViewSpy
        
        //when
        presenter.viewDidLoad()
        
        //then
        XCTAssertTrue(webViewSpy.loadRequestCalled)
    }
    
    func testProgressVisibleWhenLessThenOne() {
        //given
        let helper = AuthHelperStub()
        let presenter = WebViewPresenter(authHelper: helper)
        let progress: Float = 0.6
        
        //when
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)
        
        //then
        XCTAssertFalse(shouldHideProgress)
    }
}

final class WebViewPresenterSpy: WebViewPresenterProtocol {
    var viewDidLoadCalled: Bool = false
    var view: WebViewViewControllerProtocol?
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didUpdateProgressValue(_ newValue: Double) {
        
    }
    
    func code(from url: URL) -> String? {
        return nil
    }
}

final class WebViewViewControllerSpy: WebViewViewControllerProtocol {
    var loadRequestCalled: Bool = false
    var presenter: WebViewPresenterProtocol?
    
    func load(request: URLRequest) {
        loadRequestCalled = true
    }
    func setProgressValue(_ newValue: Float) {
        
    }
    func setProgressHidden(_ isHidden: Bool) {
        
    }
}

final class AuthHelperStub: AuthHelperProtocol {
    func authRequest() -> URLRequest? {
        guard let url = URL(string: "https://example.com") else { return nil }
        
        return URLRequest(url: url)
    }
    
    func code(from url: URL) -> String? {
        return nil
    }
}
