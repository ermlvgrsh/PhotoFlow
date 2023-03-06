import Foundation

final class ImageListService {
    
    private (set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    
    static let didChangeNotification = Notification.Name(rawValue: "ImageListServiceDidChange")
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var token = OAuth2Service.shared.authToken
    static let shared = ImageListService()
    
    
    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
        let nextPage = lastLoadedPage == nil ? 1 : lastLoadedPage! + 1
        
        guard let token = token,
              task == nil else { return }
    
        guard var request = makePhotoRequest(page: nextPage, perPage: 10) else { return }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = urlSession.objectTask(for: request) {(result: Result<[PhotoResult], Error>) in
            switch result {
            case .success(let array):
                DispatchQueue.main.async {
                    var photoResult : [PhotoResult] = []
                    photoResult += array
                    let photo = photoResult.map { photo in
                        Photo(id: photo.id,
                              size: CGSize(width: photo.width, height: photo.height),
                              createdAt: photo.createdAt,
                              welcomeDescription: photo.description,
                              thumbImageURL: photo.urls.thumb,
                              largeImageURL: photo.urls.full,
                              isLiked: photo.isLiked)
                    }
                    NotificationCenter.default
                                      .post(name: ImageListService.didChangeNotification,
                                            object: self,
                                            userInfo: ["photo": photo])
                    self.photos += photo
                    self.task = nil
                }
            case.failure(let error): print(error)
            }
        }
        self.task = task
        task.resume()
    }
    
   private func makePhotoRequest(page: Int, perPage: Int) -> URLRequest? {
        URLRequest.makeHTTPRequest(path: "/photos?"
                                   + "page=\(page)"
                                   + "&&per_page=\(perPage)",
                                   httpMethod: "GET")
    }
   
}

private extension URLRequest {
    static func makeHTTPRequest(
        path: String,
        httpMethod: String,
        baseURL: URL? = Constants().defaultBaseURL
    ) -> URLRequest? {
        guard let baseURL = baseURL else { return nil }
        guard let url = URL(string: path, relativeTo: baseURL) else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        return request
    }
    
}
