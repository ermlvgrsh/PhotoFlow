import Foundation

//добавляем структуру для декодинга ответа Unsplash
struct OAuthTokenResponseBody: Decodable {
    let accessToken: String
    let tokenType: String
    let scope: String
    let createdAt: Int
    //создаем ключи соответствия по параметрам ответа
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case scope = "scope"
        case createdAt = "created_at"
    }

}

protocol NetworkRouting {
    func fetchOAuthToken(_ code: String,
                         completion: @escaping (Result<String, Error>) -> Void)
}



















