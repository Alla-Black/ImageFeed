import Foundation
import CoreGraphics

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let fullImageURL: String
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

struct LikeResponse: Decodable {
    let photo: PhotoResult
}

final class ImagesListService {
    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private var isLoadingNextPage = false
    private var currentTask: URLSessionDataTask?
    private var isChangingLike = false
    private var likeTask: URLSessionDataTask?
    
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
    
    static let shared = ImagesListService()
    private init() {}
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    func fetchPhotosNextPage() {
        guard !isLoadingNextPage else { return }
        guard currentTask == nil else { return }
        
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
            
            if let error {
                DispatchQueue.main.async {
                    self.isLoadingNextPage = false
                    self.currentTask = nil
                }
                print("[fetchPhotosNextPage ImagesListService]: transport error: \(error) [page=\(nextPage)]")
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
                print("[fetchPhotosNextPage ImagesListService]: bad response or no data")
                return
            }
            
            do {
                let results = try decoder.decode([PhotoResult].self, from: data)
                
                let newPhotos = results.map { self.map($0) }
                
                DispatchQueue.main.async {
                    let existingIds = Set(self.photos.map { $0.id })
                    let unique = newPhotos.filter { !existingIds.contains($0.id) }
                    self.photos.append(contentsOf: unique)
                    
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
                print("[fetchPhotosNextPage ImagesListService]: decode error: \(error)")
                return
            }
        }
        
        self.currentTask = task
        task.resume()
    }
    
    private func map(_ r: PhotoResult) -> Photo {
        .init(
            id: r.id,
            size: CGSize(width: CGFloat(r.width), height: CGFloat(r.height)),
            createdAt: r.createdAt,
            welcomeDescription: r.description,
            thumbImageURL: r.urls.small,
            largeImageURL: r.urls.regular,
            fullImageURL: r.urls.full,
            isLiked: r.likedByUser
            )
    }
    
    private func makePhotoRequest(token: String, page: Int) -> URLRequest? {
        var urlComponents = URLComponents()
        urlComponents.scheme = Constants.defaultScheme
        urlComponents.host = Constants.apiHost
        urlComponents.path = Constants.photosPath
        
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "per_page", value: "10")
        ]
        
        guard let photosUrl = urlComponents.url else {
            return nil
        }
        
        var request = URLRequest(url: photosUrl)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        return request
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        if isChangingLike { return }
        isChangingLike = true
        
        guard let token = OAuth2TokenStorage.shared.token else {
            self.isChangingLike = false
            completion(.failure(URLError(.userAuthenticationRequired)))
            return
        }
        
        guard let request = makeLikeRequest(token: token, photoId: photoId, isLike: isLike) else {
            self.isChangingLike = false
            completion(.failure(URLError(.badURL)))
            return
        }
        
        self.likeTask = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self else { return }
            
            if let error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                    self.isChangingLike = false
                    self.likeTask = nil
                }
                print("[changeLike ImagesListService]: transport error: \(error) [photoId=\(photoId), isLike=\(isLike)]")
                return
            }
            
            guard
                let http = response as? HTTPURLResponse,
                (200...299).contains(http.statusCode),
                let data = data
            else {
                DispatchQueue.main.async {
                    completion(.failure(URLError(.badServerResponse)))
                    self.isChangingLike = false
                    self.likeTask = nil
                }
                print("[changeLike ImagesListService]: bad response [photoId=\(photoId), isLike=\(isLike)]")
                return
            }
            
            do {
                let likeResponse = try decoder.decode(LikeResponse.self, from: data)
                let photoResult = likeResponse.photo
                let updatedPhoto = self.map(photoResult)
                
                // Обновление массива фото после лайка
                DispatchQueue.main.async {
                if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                    self.photos[index] = updatedPhoto
                }
                
                    self.isChangingLike = false
                    self.likeTask = nil
                    completion(.success(()))
                }
            }
            
            catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                    self.isChangingLike = false
                    self.likeTask = nil
                }
                print("[changeLike ImagesListService]: decode error: \(error) [photoId=\(photoId), isLike=\(isLike)]")
                return
            }
        }
        self.likeTask?.resume()
    }
    
    private func makeLikeRequest(token: String, photoId: String, isLike: Bool) -> URLRequest? {
        var urlComponents = URLComponents()
        urlComponents.scheme = Constants.defaultScheme
        urlComponents.host = Constants.apiHost
        urlComponents.path = Constants.photosPath + "/\(photoId)/like"
        
        guard let statusLikeUrl = urlComponents.url else {
            return nil
        }
        
        var request = URLRequest(url: statusLikeUrl)
        request.httpMethod = isLike ? HTTPMethod.post.rawValue : HTTPMethod.delete.rawValue
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        return request
    }
    
    func reset() {
        currentTask?.cancel()
        currentTask = nil
        
        self.likeTask?.cancel()
        self.likeTask = nil
        
        DispatchQueue.main.async {
            
            self.isLoadingNextPage = false
            self.isChangingLike = false
            self.lastLoadedPage = nil
            
            self.photos.removeAll()
            
            NotificationCenter.default.post(
                name: ImagesListService.didChangeNotification,
                object: self
            )
        }
    }
}
