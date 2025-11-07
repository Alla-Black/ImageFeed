import Foundation

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURL: URL
    let authURLString: String
    
    let defaultScheme: String
    let defaultHost: String
    let apiHost: String
    let oauthPath: String
    let photosPath: String
    
    init(accessKey: String, secretKey: String, redirectURI: String, accessScope: String, defaultBaseURL: URL, authURLString: String, defaultScheme: String, defaultHost: String, apiHost: String, oauthPath: String, photosPath: String) {
        
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.defaultBaseURL = defaultBaseURL
        self.authURLString = authURLString
        self.defaultScheme = defaultScheme
        self.defaultHost = defaultHost
        self.apiHost = apiHost
        self.oauthPath = oauthPath
        self.photosPath = photosPath
    }
    
    static var standard: AuthConfiguration {
        return AuthConfiguration(
            accessKey: Constants.accessKey,
            secretKey: Constants.secretKey,
            redirectURI: Constants.redirectURI,
            accessScope: Constants.accessScope,
            defaultBaseURL: Constants.defaultBaseURL,
            authURLString: Constants.unsplashAuthorizeURLString,
            defaultScheme: Constants.defaultScheme,
            defaultHost: Constants.defaultHost,
            apiHost: Constants.apiHost,
            oauthPath: Constants.oauthPath,
            photosPath: Constants.photosPath
        )
    }
}
