import Foundation

protocol ProfileServiceProtocol {
    var profile: Profile? { get }
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void)
}
final class ProfileService: ProfileServiceProtocol {
 
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    static let shared = ProfileService()
    private(set) var profile: Profile?
    private var configuration = AuthConfiguration.standart
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        if lastCode == token { return }
        task?.cancel()
        lastCode = token
        
        let url = URL(string: configuration.stringMe)
        var request = URLRequest(url: bindSome(for: url))
        
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = urlSession.objectTask(for: request) { (result: Result<ProfileResult, Error>) in
            switch result {
            case.success(let profileResult):
                let converter = self.convert(from: profileResult)
                self.profile = converter
                completion(.success(converter))
            case .failure(let error): completion(.failure(error))
            }
        }
        self.task = task
        task.resume()
    }
    func convert(from result: ProfileResult) -> Profile {
        let profile = Profile(username: result.username,
                              name: "\(result.firstName) \(result.lastName)",
                              loginName: "@\(result.username)",
                              bio: result.bio)
        return profile
    }
}







