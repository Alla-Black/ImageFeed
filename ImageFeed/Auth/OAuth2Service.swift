import Foundation

struct OAuthTokenResponseBody: Decodable {
    var access_token: String
}

final class OAuth2Service {
    static let shared = OAuth2Service()
    private init() {}
    
    private let tokenStorage = OAuth2TokenStorage()
    private var task: URLSessionTask?
    private var lastCode: String?
    
    func fetchAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        if lastCode == code {
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        if task != nil {
            task?.cancel()
        }
        
        lastCode = code
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            completion(.failure(NetworkError.invalidRequest))
            lastCode = nil
            return
        }
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            guard let self else { return }
            
            switch result {
            case .success(let data):
               
                    print(data.access_token)
                    
                self.tokenStorage.token = data.access_token
                    completion(.success(data.access_token))
                    
                    self.task = nil
                    self.lastCode = nil
                
            case .failure(let error):
                print("[OAuth2Service]: failure - code: \(code) - reason: \(error.localizedDescription)")
                completion(.failure(error))
                
                self.task = nil
                self.lastCode = nil
            }
        }
    
            self.task = task
            task.resume()
        }
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        var urlComponents = URLComponents()
        urlComponents.scheme = Constants.defaultScheme
        urlComponents.host = Constants.defaultHost
        urlComponents.path = Constants.oauthPath
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        
        guard let authTokenUrl = urlComponents.url else { return nil }
        
        var request = URLRequest(url: authTokenUrl)
        request.httpMethod = "POST"
        
        return request
    }
}

