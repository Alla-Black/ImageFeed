@testable import ImageFeed
import XCTest

final class ProfileImageServiceStub: ProfileImageServiceProtocol {
    var avatarURL: String?
    let didChangeNotification = Notification.Name("ProfileImageServiceStub.didChange")
}
