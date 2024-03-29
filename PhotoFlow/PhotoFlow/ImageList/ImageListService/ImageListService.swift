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
        let nextPage = getNextPage()
        
        guard let token = token,
              task == nil,
              var request = makePhotoRequest(page: nextPage, perPage: 10) else { return }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = urlSession.objectTask(for: request) {[weak self] (result: Result<[PhotoResult], Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let photoResult):
               DispatchQueue.main.async {
                   photoResult.forEach { result in
                       let photo = self.convertToPhoto(from: result)
                       self.photos.append(photo)
                       NotificationCenter.default.post(
                        name: ImageListService.didChangeNotification,
                        object: self,
                        userInfo: ["photos" : self.photos])
                   }
                }
            case.failure(let error): assertionFailure("Couldn't catch Flow - \(error)")
            }
        }
        self.task = task
        task.resume()
    }
    
    private func convertToPhoto(from photoResult: PhotoResult) -> Photo {
        return Photo(id: photoResult.id,
                     size: CGSize(width: photoResult.width, height: photoResult.height),
                     createdAt: self.convertDate(from:photoResult.createdAt),
                     welcomeDescription: photoResult.description,
                     thumbImageURL: photoResult.urls.thumb,
                     largeImageURL: photoResult.urls.full,
                     isLiked: photoResult.isLiked)
       }

       
       func changeLike(photoID: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
           
           guard var request = isLike ? makeLikeRequest(photoID: photoID) : removeLikeRequest(photoID: photoID),
           let token = token else { return }
           request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

           let task = urlSession.objectTask(for: request) { [weak self] (result: Result<Like, Error>) in
               guard let self = self else { return }
               switch result {
               case .success:
                       guard let index = self.photos.firstIndex(where: {$0.id == photoID}) else { return }
                       let photo = self.photos[index]
                       let newPhoto = Photo(id: photo.id,
                                            size: photo.size,
                                            createdAt: photo.createdAt,
                                            welcomeDescription: photo.welcomeDescription,
                                            thumbImageURL: photo.thumbImageURL,
                                            largeImageURL: photo.largeImageURL,
                                            isLiked: !photo.isLiked)
                       self.photos[index] = newPhoto
                       completion(.success(()))
               case .failure(let error):
               assertionFailure("Couldn't like photo - \(error)")
               }
           }
           task.resume()
       }
    private func convertDate(from string: String) -> Date? {
           
           let dateFormatter = ISO8601DateFormatter()
           let date = dateFormatter.date(from: string)
           return date
       }
       
       private func makePhotoRequest(page: Int, perPage: Int) -> URLRequest? {
           URLRequest.makeHTTPRequest(path: "/photos?"
                                      + "page=\(page)"
                                      + "&&per_page=\(perPage)",
                                      httpMethod: "GET")
       }
       func getFullImageURL(with indexPath: IndexPath) -> URL {
           let imageURL = photos[indexPath.row].largeImageURL
           guard let url = URL(string: imageURL) else { preconditionFailure("Unable to get URL")}
           return url
       }
       func getNextPage() -> Int {
           guard var lastLoadedPage = lastLoadedPage else {
               self.lastLoadedPage = 1
               return 1
           }
           lastLoadedPage += 1
           self.lastLoadedPage = lastLoadedPage
           return lastLoadedPage
       }
       
       
       func makeLikeRequest(photoID: String) -> URLRequest? {
           URLRequest.makeHTTPRequest(path: "/photos/\(photoID)/like", httpMethod: "POST")
       }
       func removeLikeRequest(photoID: String) -> URLRequest? {
           URLRequest.makeHTTPRequest(path: "/photos/\(photoID)/like", httpMethod: "DELETE")
       }
   }

   private extension URLRequest {
       static func makeHTTPRequest(
           path: String,
           httpMethod: String,
           baseURL: URL? = AuthConfiguration.standart.defaultBaseURL
       ) -> URLRequest? {
           guard let baseURL = baseURL else { return nil }
           guard let url = URL(string: path, relativeTo: baseURL) else { return nil }
           var request = URLRequest(url: url)
           request.httpMethod = httpMethod
           return request
       }
       
   }
