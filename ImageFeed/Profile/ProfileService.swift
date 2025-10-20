import Foundation

struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String?
}

struct ProfileResult: Codable {
    let username: String
    let first_name: String
    let last_name: String?
    let bio: String?
    
    enum CodingKeys: String, CodingKey {
        case username
        case first_name = "first_name"
        case last_name = "last_name"
        case bio
    }
}

final class ProfileService {
    static let profileService = ProfileService()
    private init() {}
    
    private var task: URLSessionTask?
    private let urlSession = URLSession.shared
    private(set) var profile: Profile?
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        task?.cancel()
        
        guard let request = makeProfileRequest(token: token) else {
            print("[ProfileService.fetchProfile]: failure - url: https://api.unsplash.com/me - reason: \(URLError(.badURL).localizedDescription)")
            
            completion(.failure(URLError(.badURL)))
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            guard let self else { return }
            
            switch result {
            case .success(let data):
                
                let lastName = data.last_name ?? ""
                let fullName = "\(data.first_name) \(lastName)".trimmingCharacters(in: .whitespaces)
                
                let profile = Profile(
                    username: data.username,
                    name: fullName,
                    loginName: "@\(data.username)",
                    bio: data.bio
                )
                    
                self.profile = profile
                completion(.success(profile))
                
            case .failure(let error):
                print("[ProfileService.fetchProfile]: failure - url: \(request.url?.absoluteString ?? "") - reason: \(error.localizedDescription)")
                
                completion(.failure(error))
            }
            self.task = nil
        }
        
        self.task = task
        task.resume()
    }
    
    private func makeProfileRequest(token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/me") else {
            return nil
        }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
    
    func reset() {
        task?.cancel()
        task = nil
        
        profile = nil
    }
}


