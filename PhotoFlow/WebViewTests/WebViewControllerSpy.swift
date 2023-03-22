import Foundation
import PhotoFlow
final class WebViewViewControllerSpy: WebViewControllerProtocol {
    var presenter: PhotoFlow.WebViewPresenterProtocol?
    var requestIsLoaded: Bool = false
    func load(request: URLRequest) {
        requestIsLoaded = true
    }
    
    func setProgressValue(_ newValue: Float) {
        
    }
    
    func setProgressHidden(_ isHidden: Bool) {
        
    }
    
    
}
