import Foundation

//инициализируем энум сетевых ошибок
enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    
}

private let defaultBaseURL = SomeData().defaultBaseURL

//реализуем класс, который взаимодействует с авторизацией на сервисе ансплэш
final class OAuth2Service: NetworkRouting {
    
 
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
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case.success(let body):
                    let authToken = body.accessToken
                    self.authToken = authToken
                    print("Hey", authToken)
                    completion(.success(authToken))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
            
        }
        task.resume()
    }

}


extension URLRequest {

    static func makeHTTPRequest (
        path: String,
        httpMethod: String,
        baseURL: URL? = defaultBaseURL) -> URLRequest {
            
            let url = URL(string: path, relativeTo: defaultBaseURL)
            
            var request = URLRequest(url: bindSome(for: url))
            request.httpMethod = httpMethod
            return request
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
        let task = dataTask(with: request) { data, response, error in
            if let data = data,
               let response = response,
               let statusCode = (response as? HTTPURLResponse)?.statusCode
            {
                if 200..<300 ~= statusCode {
                    print("YO",statusCode)
                    fulfillCompletion((.success(data)))
                } else {
                    return fulfillCompletion(.failure(NetworkError.httpStatusCode(statusCode)))
                }
            } else if let error = error {
                fulfillCompletion(.failure(NetworkError.urlRequestError(error)))
            } else {
                fulfillCompletion(.failure(NetworkError.urlSessionError))
                
                
            }
          
        }
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
    private func authTokenRequest(code: String) -> URLRequest? {
        
        let someData = SomeData()
        let urlString = "https://unsplash.com/ouath/token"
        var urlComponents = URLComponents(string: urlString)
        urlComponents?.queryItems = [
            URLQueryItem(name: "client_id", value: someData.accessKey),
            URLQueryItem(name: "client_secret", value: someData.secretKey),
            URLQueryItem(name: "redirect_uri", value: someData.redirectUri),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        guard let url = urlComponents?.url else { return nil }
            
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }

}

private func bindSome<T>(for url: T?) -> T {
    guard let url = url else { preconditionFailure("Unable to bind")}
    return url
}
