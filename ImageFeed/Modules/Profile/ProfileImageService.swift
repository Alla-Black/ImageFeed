import Foundation

// MARK: - ProfileImageServiceProtocol
public protocol ProfileImageServiceProtocol {
    var avatarURL: String? { get }
    var didChangeNotification: Notification.Name { get }
}

// MARK: - ProfileImage
struct ProfileImage: Codable {
    let small: String
}

// MARK: - UserResult
struct UserResult: Codable {
    let profileImage: ProfileImage
    
    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}

// MARK: - ProfileImageService
final class ProfileImageService {
    // MARK: - Static Properties
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    // MARK: - Singleton
    static let shared = ProfileImageService()
    private init() {}
    
    // MARK: - Private Properties
    private var task: URLSessionTask?
    private let urlSession = URLSession.shared
    private(set) var avatarURL: String?
    
    // MARK: - Public Methods
    func fetchProfileImageURL(username: String, _ completion: @escaping(Result<String, Error>) -> Void) {
        task?.cancel()
        
        guard let token = OAuth2TokenStorage.shared.token else {
            print("[ProfileImageService.fetchProfileImageURL]: failure - reason: authorisation token missing - username: \(username)")
            
            completion(.failure(NSError(domain: "ProfileImageService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Authorisation token missing"])))
            return
        }
        
        guard let request = makeProfileImageRequest(username: username, token: token) else {
            print("[ProfileImageService.fetchProfileImageURL]: failure - reason: \(URLError(.badURL).localizedDescription) - url: https://api.unsplash.com/users/\(username)")
            
            completion(.failure(URLError(.badURL)))
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            guard let self else { return }
            
            switch result {
            case .success(let data):
                
                self.avatarURL = data.profileImage.small
                completion(.success(data.profileImage.small))
                
                NotificationCenter.default
                    .post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["URL": data.profileImage.small]
                    )
                
            case .failure(let error):
                print("[ProfileImageService.fetchProfileImageURL]: failure - url: \(request.url?.absoluteString ?? "") - username: \(username) - reason: \(error.localizedDescription)")
                
                completion(.failure(error))
            }
            self.task = nil
        }
        
        self.task = task
        task.resume()
    }
    
    func reset() {
        task?.cancel()
        task = nil
        
        avatarURL = nil
        
        NotificationCenter.default.post(
            name: ProfileImageService.didChangeNotification,
            object: self
        )
    }
    
    // MARK: - Private Methods
    private func makeProfileImageRequest(username: String, token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/users/\(username)") else {
            return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
    
}

//MARK: - ProfileImageServiceProtocol
extension ProfileImageService: ProfileImageServiceProtocol {
    public var didChangeNotification: Notification.Name { Self.didChangeNotification }
}


