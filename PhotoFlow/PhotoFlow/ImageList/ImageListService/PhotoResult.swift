import Foundation

struct PhotoResult: Codable {
    let id: String
    let width: Int
    let height: Int
    let createdAt: Date?
    let description: String
    let thumbImageURL: URLsResult
    let largeImageURL: URLsResult
    let isLiked: Bool
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case width = "width"
        case height = "height"
        case createdAt = "created_at"
        case description = "description"
        case isLiked = "liked_by_user"
        case thumbImageURL = "thumb"
        case largeImageURL = "large"
    }
}

struct URLsResult: Codable {
    let urls: [String : String]
    
    enum CodingKeys: String, CodingKey {
        case urls = "urls"
    }
}
