import Foundation

final class ProfileService {
 
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    static let shared = ProfileService()
    private(set) var profile: Profile?
    private var configuration = AuthConfiguration.standart
    
    func fetchProfile(token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
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
                guard let profile = self.profile?.convert(from: profileResult) else { return }
                self.profile = profile
                completion(.success(profile))
            case .failure(let error): completion(.failure(error))
            }
        }
        self.task = task
        task.resume()
    }
}







