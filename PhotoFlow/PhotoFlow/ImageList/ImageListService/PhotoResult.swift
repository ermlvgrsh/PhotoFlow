import Foundation

// MARK: - PhotoResultElement
struct PhotoResult: Codable {
    let urls: URLsResult
    let isLiked: Bool
    let id: String
    let createdAt: String
    let width, height: Int
    let description: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case width, height, description, urls
        case isLiked = "liked_by_user"
        
    }
}
// MARK: - Urls
struct URLsResult: Codable {
    let thumb: String
    let full: String
}

//MARK: - Likes
struct Like: Codable {
    let photo: PhotoResult
}
