import Foundation


public protocol WebViewPresenterProtocol {
    var view: WebViewControllerProtocol? { get set }
    func viewDidLoad()
    func didUpdateProgressValue(_ newValue: Double)
    func code(from url: URL) -> String?
}

final class WebViewPresenter: WebViewPresenterProtocol {
    
    weak var view: WebViewControllerProtocol?
    var authHelper: AuthHelperProtocol
    var configuration = AuthConfiguration.standart
    
    init(authHelper: AuthHelperProtocol) {
        self.authHelper = authHelper
    }

    func viewDidLoad() {
        guard let request = authHelper.authRequest() else { return }                 //формируем URL запрос
        view?.load(request: request)
        didUpdateProgressValue(0)
     
    }
    
    func didUpdateProgressValue(_ newValue: Double) {
        let newProgressValue = Float(newValue)
        view?.setProgressValue(newProgressValue)
        
        let shouldHideProgress = self.shouldHideProgress(for: newProgressValue)
        view?.setProgressHidden(shouldHideProgress)
    }
    
    func shouldHideProgress(for value: Float) -> Bool {
        abs(value - 1.0) <= 0.0001
    }
    
    func code(from url: URL) -> String? {
        authHelper.code(from: url)          // используем хэлпер
    }
}
private extension WebViewPresenter {
    func createAuthRequest() -> URLRequest? {
        var urlComponents = URLComponents(string: configuration.authURLString)
        urlComponents?.queryItems = [
            URLQueryItem(name: "client_id", value: configuration.accessKey),
            URLQueryItem(name: "redirect_uri", value: configuration.redirectUri),
            URLQueryItem(name: "scope", value: configuration.accessScope),
            URLQueryItem(name: "response_type", value: "code"),
        ]
        urlComponents?.path = "/oauth/authorize"
        
        guard let url = urlComponents?.url else { return nil }
        return URLRequest(url: url)
    }
}
