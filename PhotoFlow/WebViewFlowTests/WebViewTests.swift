import XCTest
@testable import PhotoFlow
import Foundation



final class WebViewTests: XCTestCase {
    
    func testViewControllerCallsViewDidLoad() {
        //given
        let viewController = WebViewViewController()
        let presenter = WebViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        _ = viewController.view
        
        //then
        XCTAssertTrue(presenter.viewDidLoadCalled) //behaviour verification
    }
    func testAuthHelperAuthURL() {
        //given
        let configuration = AuthConfiguration.standart
        let authHelper = AuthHelper(configuration: configuration)
        
        //when
        guard let url = authHelper.authURL() else { return }
        let urlString = url.absoluteString
        
        //then
        XCTAssertTrue(urlString.contains(configuration.authURLString))
        XCTAssertTrue(urlString.contains(configuration.accessKey))
        XCTAssertTrue(urlString.contains(configuration.redirectUri))
        XCTAssertTrue(urlString.contains(configuration.code))
        XCTAssertTrue(urlString.contains(configuration.accessScope))
        
    }
    
    func testPresenterCallsLoadRequest() {
        //given
        let viewController = WebViewViewControllerSpy()
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        viewController.presenter = presenter
        presenter.view = viewController
        //when
        presenter.viewDidLoad()
        
        //then
        XCTAssertTrue(viewController.requestIsLoaded)
    }
    
    func testProgressVisibleWhenLessThenOne() {
        //given
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 0.6
        
        //when
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)
        
        //then
        XCTAssertFalse(shouldHideProgress)
    }
    
    func testProgressHiddenWhenOne() {
        //given
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 1.0
        
        //when
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)
        
        //then
        XCTAssertTrue(shouldHideProgress)
    }
        func testCodeFromURL() {
            //given
            guard var urlComponents = URLComponents(string: "https://unsplash.com/") else { return }
            urlComponents.path = "oauth/authorize/native"
            urlComponents.queryItems = [URLQueryItem(name: "code", value: "test code")]
            guard let url = urlComponents.url else { return }
            let authHelper = AuthHelper()
            
            //when
            guard let code = authHelper.code(from: url) else { return }
            
            //then
            XCTAssertEqual(code, "test code")
        }
}
