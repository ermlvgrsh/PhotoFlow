import Foundation

struct Profile {
    let username: String
    var name: String
    let loginName: String
    let bio: String?
 
    func convert(from result: ProfileResult) -> Profile {
        let profile = Profile(username: result.username,
                              name: "\(result.firstName) \(result.lastName)",
                              loginName: "@\(result.username)",
                              bio: result.bio)
        return profile
    }
}
