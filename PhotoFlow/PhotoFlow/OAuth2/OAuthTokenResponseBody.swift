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
        case scope 
        case createdAt = "created_at"
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.accessToken = try container.decode(String.self, forKey: .accessToken)
        self.tokenType = try container.decode(String.self, forKey: .tokenType)
        self.scope = try container.decode(String.self, forKey: .scope)
        self.createdAt = try container.decode(Int.self, forKey: .createdAt)
    }

}




















