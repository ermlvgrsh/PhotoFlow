import Foundation

//инициализируем энум сетевых ошибок
enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    
}

private let defaultBaseURL = SomeData().defaultBaseURL

//реализуем класс, который взаимодействует с авторизацией на сервисе ансплэш
final class OAuth2Service {
    
    
    //доступ к единственному экземпляру класса (синглтон)
    static let shared = OAuth2Service()
    private let urlSession = URLSession.shared
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
        
        let request = authTokenRequest(code: code)
        let task = object(for: request) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case.success(let body):
                let authToken = body.accessToken
                self.authToken = authToken
                SplashViewController().switchTabBarController()
                completion(.success(authToken))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    
    
}


extension URLSession {
    func data(
        for request: URLRequest,
        completion: @escaping (Result <Data, Error>) -> Void)
    -> URLSessionTask {
        let fulfillCompletion: (Result <Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        let task = dataTask(with: request, completionHandler:  { data, response, error in
            if let data = data,
               let response = response,
               let statusCode = (response as? HTTPURLResponse)?.statusCode
            {
                if 200..<300 ~= statusCode {
                    fulfillCompletion((.success(data)))
                } else {
                    return fulfillCompletion(.failure(NetworkError.httpStatusCode(statusCode)))
                }
            } else if let error = error {
                fulfillCompletion(.failure(NetworkError.urlRequestError(error)))
            } else {
                fulfillCompletion(.failure(NetworkError.urlSessionError))
                
                
            }
          
        })
        task.resume()
        return task
    }
}


extension OAuth2Service {
    private func object(
        for request: URLRequest?,
        completion: @escaping (Result<OAuthTokenResponseBody, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()
        return urlSession.data(for: bindSome(for: request)) { (result: Result<Data, Error>) in
            let response = result.flatMap { data -> Result<OAuthTokenResponseBody, Error> in
                Result {
                    try decoder.decode(OAuthTokenResponseBody.self, from: data)
                }
            }
            completion(response)
        }
        
    }
    private func authTokenRequest(code: String) -> URLRequest {
        
        let urlString = "https://unsplash.com/oauth/token"
        var urlComponents = URLComponents(string: urlString)
        urlComponents?.queryItems = [URLQueryItem(name: "client_id", value: SomeData().accessKey),
                                     URLQueryItem(name: "client_secret", value: SomeData().secretKey),
                                     URLQueryItem(name: "redirect_uri", value: SomeData().redirectUri),
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
