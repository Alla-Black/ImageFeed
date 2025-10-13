import Testing
@testable import ImageFeed
import XCTest

final class ImagesListServiceTests: XCTestCase {
    func testFetchPhotos() {
        let service = ImagesListService()
        
        let expectation = self.expectation(description: "Wait for Notification")
        NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: service,
            queue: .main) { _ in
                expectation.fulfill()
            }
        
        let token = OAuth2TokenStorage.shared.token
        XCTAssertNotNil(token, "В тестовой среде нет токена — запрос не стартует")
        service.fetchPhotosNextPage()
        wait(for: [expectation], timeout: 10)
        
        XCTAssertEqual(service.photos.count, 10)
    }
}
