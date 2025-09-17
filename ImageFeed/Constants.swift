import Foundation

enum Constants {
    static let accessKey = "7KYXtrTofya9kTzJtmTqARXUgvOulkBdpqmF1RATbMQ"
    static let secretKey = "Pcm22qIw43UMY_lysyBpLVhngdPJW_0fFj8d8SKBXDI"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let defaultBaseURL = URL(string: "https://api.unsplash.com/")!
    
    static let defaultScheme = "https"
    static let defaultHost = "unsplash.com"
    static let oauthPath = "/oauth/token"
}
