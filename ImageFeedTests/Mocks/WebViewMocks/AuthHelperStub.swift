import XCTest
@testable import ImageFeed

final class AuthHelperStub: AuthHelperProtocol {
    func authRequest() -> URLRequest? {
        guard let url = URL(string: "https://example.com") else { return nil }
        
        return URLRequest(url: url)
    }
    
    func code(from url: URL) -> String? {
        return nil
    }
}

