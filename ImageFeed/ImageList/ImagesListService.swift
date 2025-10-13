import Foundation
import CoreGraphics

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}

struct UrlsResult: Decodable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
}

struct PhotoResult: Decodable {
    let id: String
    let createdAt: Date?
    let width: Int
    let height: Int
    let likes: Int
    let likedByUser: Bool
    let description: String?
    let urls: UrlsResult
    
    enum CodingKeys: String, CodingKey {
        case id, width, height, likes, urls, description
        case createdAt = "created_at"
        case likedByUser = "liked_by_user"
    }
}

final class ImagesListService {
    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private var isLoadingNextPage = false
    private var currentTask: URLSessionDataTask?
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private func map(_ r: PhotoResult) -> Photo {
        .init(
            id: r.id,
            size: CGSize(width: CGFloat(r.width), height: CGFloat(r.height)),
            createdAt: r.createdAt,
            welcomeDescription: r.description,
            thumbImageURL: r.urls.small,
            largeImageURL: r.urls.regular,
            isLiked: r.likedByUser
            )
    }
    
    func fetchPhotosNextPage() {
        if isLoadingNextPage { return }
        if currentTask != nil { return }
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        isLoadingNextPage = true
        
        guard let token = OAuth2TokenStorage.shared.token else {
            isLoadingNextPage = false
            return
        }
        
        guard let request = makePhotoRequest(token: token, page: nextPage) else {
            isLoadingNextPage = false
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.isLoadingNextPage = false
                    self.currentTask = nil
                }
                print("ImagesListService transport error: \(error)")
                return
            }
            
            guard
                let http = response as? HTTPURLResponse,
                (200...299).contains(http.statusCode),
                let data = data
            else {
                DispatchQueue.main.async {
                    self.isLoadingNextPage = false
                    self.currentTask = nil
                }
                print("ImagesListService bad response or no data")
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let results = try decoder.decode([PhotoResult].self, from: data)
                
                let newPhotos = results.map { self.map($0) }
                
                DispatchQueue.main.async {
                    self.photos.append(contentsOf: newPhotos)
                    self.lastLoadedPage = nextPage
                    self.isLoadingNextPage = false
                    self.currentTask = nil
                    NotificationCenter.default.post(
                        name: ImagesListService.didChangeNotification,
                        object: self
                    )
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoadingNextPage = false
                    self.currentTask = nil
                }
                print("ImagesListService decode error: \(error)")
                return
            }
        }
        
        self.currentTask = task
        task.resume()
    }
    
    private func makePhotoRequest(token: String, page: Int) -> URLRequest? {
        var urlComponents = URLComponents()
        urlComponents.scheme = Constants.defaultScheme
        urlComponents.host = Constants.defaultHost
        urlComponents.path = Constants.photosPath
        
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "per_page", value: "10")
        ]
        
        guard let photosUrl = urlComponents.url else {
            return nil
        }
        
        var request = URLRequest(url: photosUrl)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        return request
    }
}
