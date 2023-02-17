import Foundation
//MARK: переменные хранящие в себе данные на доступ при авторизации
struct Constants {
    let accessKey = "ENuMv6Q_pxhXCtpyxN2mYbKJaWrlfl25vCRVefARyNo"
    let secretKey = "LtdQrrc4tqQZVr00ljNC0SsZZq61BrXQvnaZEh6ijeA"
    let redirectUri = "urn:ietf:wg:oauth:2.0:oob"
    let accessScope = "public+read_user+write_likes"
    let defaultBaseURL = URL(string: "https://api.unsplash.com")
    let unsplashAuthorizeString = "https://unsplash.com/oauth/authorize"
    let code = "code"
}

