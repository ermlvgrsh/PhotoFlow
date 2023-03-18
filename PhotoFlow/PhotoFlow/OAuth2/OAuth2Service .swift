import Foundation

//инициализируем энум сетевых ошибок
enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
}

private let defaultBaseURL = Constants().defaultBaseURL

//реализуем класс, который взаимодействует с авторизацией на сервисе ансплэш
final class OAuth2Service {
    
    
    //доступ к единственному экземпляру класса (синглтон)
    static let shared = OAuth2Service()
    private init() {}
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    //доступ к последнему полученному токену
    private (set) var authToken : String? {
        get {
            return OAuth2TokenStorage().token
        }
        set {
            OAuth2TokenStorage().token = newValue
        }
    }
    //метод в который передается код из ВебВью и через замыкание и другие функции возвращает полученный токен
    func fetchOAuthToken(_ code: String,
                         completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        if lastCode == code { return }
        task?.cancel()
        lastCode = code
        let request = authTokenRequest(code: code)
        let task = object(for: request) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case.success(let body):
                let authToken = body.accessToken
                self.authToken = authToken
                completion(.success(authToken))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
}
extension URLSession {
    
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping(Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let task = dataTask(with: request, completionHandler: { data, response, error in
            DispatchQueue.main.async {
                guard let error = error else {
                    guard let response = response,
                          let data = data,
                          let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                        return completion(.failure(NetworkError.urlSessionError))}
                    
                    guard 200..<300 ~= statusCode else { return completion(.failure(NetworkError.httpStatusCode(statusCode)))}
                    let decoder = JSONDecoder()
                    guard let json = try? decoder.decode(T.self, from: data) else { return }
                    completion(.success(bindSome(for: json)))
                    return
                }
                return completion(.failure(NetworkError.urlRequestError(error)))
            }
         })
            
        return task
    }
}



extension OAuth2Service {
    private func object(
        for request: URLRequest,
        completion: @escaping (Result<OAuthTokenResponseBody, Error>) -> Void
    ) -> URLSessionTask {
        return urlSession.objectTask(for: request) { result in
            completion(result)
        }
    }
    
    private func authTokenRequest(code: String) -> URLRequest {
        
        let urlString = "https://unsplash.com/oauth/token"
        var urlComponents = URLComponents(string: urlString)
        urlComponents?.queryItems = [URLQueryItem(name: "client_id", value: Constants().accessKey),
                                     URLQueryItem(name: "client_secret", value: Constants().secretKey),
                                     URLQueryItem(name: "redirect_uri", value: Constants().redirectUri),
                                     URLQueryItem(name: "code", value: code),
                                     URLQueryItem(name: "grant_type", value: "authorization_code"),
        ]
        var request = URLRequest(url: bindSome(for: urlComponents?.url))
        request.httpMethod = "POST"
        return request
        
    }
    
}

func bindSome<T>(for thing: T?) -> T {
    guard let some = thing else { preconditionFailure("Unable to bind")}
    return some
}
