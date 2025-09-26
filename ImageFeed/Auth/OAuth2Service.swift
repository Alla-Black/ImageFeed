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
        
        let task = URLSession.shared.data(for: request) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                
                switch result {
                case .success(let data):
                    do {
                        let decoder = JSONDecoder()
                        let responseBody = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                        print(responseBody.access_token)
                        self.tokenStorage.token = responseBody.access_token
                        completion(.success(responseBody.access_token))
                        self.task = nil
                        self.lastCode = nil
                    }
                    catch {
                        print(error)
                        completion(.failure(NetworkError.decodingError(error)))
                        self.task = nil
                        self.lastCode = nil
                    }
                case .failure(let error):
                    print(error)
                    completion(.failure(error))
                    self.task = nil
                    self.lastCode = nil
                }
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

