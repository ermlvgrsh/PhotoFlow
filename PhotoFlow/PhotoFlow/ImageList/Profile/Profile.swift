import Foundation

struct Profile {
    private let firstName: String
    private let lastName: String
    let username: String
    var name: String {
        return firstName + " " + lastName
    }
    let loginName: String
    let bio: String?
 
    init(from result: ProfileResult) {
        firstName = result.firstName
        lastName = result.lastName
        username = result.username
        loginName = "@" + username
        bio = result.bio
    }
}
