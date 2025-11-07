import XCTest
@testable import ImageFeed


final class ImagesListServiceStub: ImagesListServiceProtocol {
    var shouldFailChangeLike = false
    enum StubError: Error { case likeFailed }
    
    var photos: [Photo] = [
        Photo(id: "1",
              size: CGSize(width: 100, height: 100),
              createdAt: Date(),
              welcomeDescription: nil,
              thumbImageURL: "",
              largeImageURL: "",
              fullImageURL: "",
              isLiked: false),
        
        Photo(id: "2",
              size: CGSize(width: 100, height: 100),
              createdAt: Date(),
              welcomeDescription: nil,
              thumbImageURL: "",
              largeImageURL: "",
              fullImageURL: "",
              isLiked: false),
        
        Photo(id: "3",
              size: CGSize(width: 100, height: 100),
              createdAt: Date(),
              welcomeDescription: nil,
              thumbImageURL: "",
              largeImageURL: "",
              fullImageURL: "",
              isLiked: false),
        
        Photo(id: "4",
              size: CGSize(width: 100, height: 100),
              createdAt: Date(),
              welcomeDescription: nil,
              thumbImageURL: "",
              largeImageURL: "",
              fullImageURL: "",
              isLiked: false),
        
        Photo(id: "5",
              size: CGSize(width: 100, height: 100),
              createdAt: Date(),
              welcomeDescription: nil,
              thumbImageURL: "",
              largeImageURL: "",
              fullImageURL: "",
              isLiked: false)
    ]
    
    static var didChangeNotification = Notification.Name("ImagesListServiceStub.didChange")
    var fetchNextPageCallCount = 0
    
    func fetchPhotosNextPage() {
        fetchNextPageCallCount += 1
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        
        if shouldFailChangeLike {
            return DispatchQueue.main.async {
                completion(.failure(StubError.likeFailed))
            }
        }
        
        if let index = photos.firstIndex(where: { $0.id == photoId }) {
            
            var updatedPhoto = photos[index]
            
            updatedPhoto = Photo(
                id: updatedPhoto.id,
                size: updatedPhoto.size,
                createdAt: updatedPhoto.createdAt,
                welcomeDescription: updatedPhoto.welcomeDescription,
                thumbImageURL: updatedPhoto.thumbImageURL,
                largeImageURL: updatedPhoto.largeImageURL,
                fullImageURL: updatedPhoto.fullImageURL,
                isLiked: isLike
            )
            
            photos[index] = updatedPhoto
        }
        
        DispatchQueue.main.async {
            completion(.success(()))
        }
    }
}

