import Foundation
import UIKit

final class ProfileImageService {
    
    private let urlSession = URLSession.shared
    private var lastToken: String?
    private var task: URLSessionTask?
    static let shared = ProfileImageService()
    private var token = OAuth2TokenStorage().token
    private(set) var avatarURL: String?
    static let DidChangeNotification = Notification.Name("ProfileImageProviderDidChange")
    
    func fetchProfileImageURL(username: String,_ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        if lastToken == token { return }
        task?.cancel()
        lastToken = token
        
        let request = makeRequestForImage(username: username, token: bindSome(for: token))
        
        task = urlSession.objectTask(for: request) { (result: Result<UserResult, Error>) in
            switch result {
            case.success(let userResults):
                guard let avatarURL = userResults.profileImage["small"] else { return }
                completion(.success(avatarURL))
                NotificationCenter.default
                    .post(name: ProfileImageService.DidChangeNotification,
                          object: self,
                          userInfo: ["URL": avatarURL])
            case .failure(let error): completion(.failure(error))
            }
        }
        task?.resume()
    }
}

extension ProfileImageService {
    func makeRequestForImage(username: String, token: String) -> URLRequest {
        
        let url = URL(string: Constants().stringUser + username)
        var request = URLRequest(url: bindSome(for: url))
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
    func setAvatarURL(avatar: String) {
        self.avatarURL = avatar
    }
}
