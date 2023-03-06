import Foundation

struct PhotoResult: Decodable {
    let id: String
    let width: Int
    let height: Int
    let createdAt: Date?
    let description: String
    let urls: URLsResult
    let isLiked: Bool
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case width = "width"
        case height = "height"
        case createdAt = "created_at"
        case description = "description"
        case isLiked = "liked_by_user"
        case urls
    }
}

struct URLsResult: Decodable {
    let thumb: String
    let full: String
}
