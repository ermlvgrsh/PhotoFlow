import UIKit

struct UserResult: Codable {
    
    var profileImage: [String: String]
    
    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
    
}
