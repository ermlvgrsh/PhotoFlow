import Foundation

let myAccessKey = "ENuMv6Q_pxhXCtpyxN2mYbKJaWrlfl25vCRVefARyNo"
let mySecretKey = "LtdQrrc4tqQZVr00ljNC0SsZZq61BrXQvnaZEh6ijeA"
let myRedirectUri = "urn:ietf:wg:oauth:2.0:oob"
let myAccessScope = "public+read_user+write_likes"

let myDefaultBaseURL = URL(string: "https://api.unsplash.com")
let myUnsplashAuthorizeString = "https://unsplash.com/oauth/authorize/native"
let myCode = "code"
let myStringMe = "https://api.unsplash.com/me"
let myStringUser = "https://api.unsplash.com/users/"
let myStringPhotos = "https://api.unsplash.com/photos"
//MARK: переменные хранящие в себе данные на доступ при авторизации
struct AuthConfiguration {
    
    let accessKey: String
    let secretKey: String
    let redirectUri: String
    let accessScope: String
    let defaultBaseURL: URL
    let authURLString: String
    let code: String
    let stringMe: String
    let stringUser: String
    let stringPhotos: String
    
    init(accessKey: String, secretKey: String, redirectUri: String, accessScope: String, defaultBaseURL: URL, authURLString: String, code: String, stringMe: String, stringUser: String, stringPhotos: String) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectUri = redirectUri
        self.accessScope = accessScope
        self.defaultBaseURL = defaultBaseURL
        self.authURLString = authURLString
        self.code = code
        self.stringMe = stringMe
        self.stringUser = stringUser
        self.stringPhotos = stringPhotos
    }
    static var standart: AuthConfiguration {
        return AuthConfiguration(accessKey: myAccessKey, secretKey: mySecretKey, redirectUri: myRedirectUri, accessScope: myAccessKey, defaultBaseURL: bindSome(for: myDefaultBaseURL), authURLString: myUnsplashAuthorizeString, code: myCode, stringMe: myStringMe, stringUser: myStringUser, stringPhotos: myStringPhotos)
    }


}
