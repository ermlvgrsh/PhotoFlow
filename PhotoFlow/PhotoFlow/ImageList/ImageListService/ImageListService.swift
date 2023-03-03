import Foundation

final class ImageListService {
    
    private (set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    static let didChangeNotification = Notification.Name(rawValue: "ImageListServiceDidChange")
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    
    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
        let nextPage = lastLoadedPage == nil ? 1 : bindSome(for: lastLoadedPage) + 1
        
        let url = URL(string: Constants().stringPhotos)
        var request = URLRequest(url: bindSome(for: url))
        
      task = urlSession.objectTask(for: request) { (result: Result<PhotoResult, Error>) in
            switch result {
            case.success(let json):
                let photoResult = PhotoResult(id: json.id,
                                              width: json.width,
                                              height: json.height,
                                              createdAt: json.createdAt,
                                              description: json.description,
                                              thumbImageURL: json.thumbImageURL,
                                              largeImageURL: json.largeImageURL,
                                              isLiked: json.isLiked)
                guard let thumb = photoResult.thumbImageURL.urls["thumb"] else { return }
                guard let large = photoResult.largeImageURL.urls["full"] else { return }
                let size = CGRect(x: 0, y: 0, width: photoResult.width, height: photoResult.height)
                let photo = Photo(id: photoResult.id,
                                  size: size,
                                  createdAt: photoResult.createdAt,
                                  welcomeDescription: photoResult.description,
                                  thumbImageURL: thumb,
                                  largeImageURL: large,
                                  isLiked: photoResult.isLiked)
                self.photos.append(photo)
                NotificationCenter.default
                    .post(name: ImageListService.didChangeNotification,
                          object: self)
            case .failure(let error): print(error.localizedDescription)
                
            }
        }
        task?.resume()
        
    }
}
