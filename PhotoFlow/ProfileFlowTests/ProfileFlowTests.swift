@testable import PhotoFlow
import XCTest
import UIKit


final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var presenter: ProfileViewPresenterProtocol?
    var image: UIImage?
    var nickName: String?
    var fullName: String?
    
    func didFetchProfile(profile: PhotoFlow.Profile) {
        self.nickName = profile.loginName
        self.fullName = profile.name
    }
    
    func didUpdateAvatar(image: UIImage) {
        self.image = image
    }
    
    func present(alert: UIAlertController) { }
}

final class ProfileViewPresenterSpy: ProfileViewPresenterProtocol {
    var view: PhotoFlow.ProfileViewControllerProtocol?
    var viewDidLoaded = false
    var didTapExitButton = false
    func viewDidLoad() {
        viewDidLoaded = true
    }
    
    func logout() {
        didTapExitButton = true
    }
    
    func profileIsLoaded() { }
    
    func profileAvatarIsLoaded() { }
    
    
}


final class ProfileFlowTests: XCTestCase {
    
    func testViewControllerDidCalled() {
        //given
        let view = ProfileViewController()
        let presenter = ProfileViewPresenterSpy()
        
        view.presenter = presenter
        presenter.view = view
        
        //when
        _ = view.view
        
        //then
        XCTAssertTrue(presenter.viewDidLoaded)
    }
    
    func testCheckingNameAndLogin() {
        //given
        let view = ProfileViewControllerSpy()
        let presenter = ProfileViewPresenter()
        
        view.presenter = presenter
        presenter.view = view
        
        let loginName = "@ermlvgrsh"
        let name = "Ermolaev Grigoriy"
        let profile = Profile(username: "ermlvgrsh", name: name, loginName: loginName, bio: nil)
        
        //when
        view.didFetchProfile(profile: profile)
        let actualName = view.fullName
        let actualNickname = view.nickName
        
        //then
        XCTAssertEqual(loginName, actualNickname)
        XCTAssertEqual(name , actualName)
    }
    
    func testProfileViewControllerShowsAvatar() {
        //given
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfileViewPresenter()
        viewController.presenter = presenter
        presenter.view = viewController
        guard let expectedImage = UIImage(named: "profilePhoto") else { return }
        
        //when
        presenter.updateAvatarImage(expectedImage)
        let actualImage = viewController.image
        
        //then
        XCTAssertEqual(expectedImage, actualImage)
        
    }
    
    func testProfilePresenterTappedLogout() {
        //given
        let viewController = ProfileViewController()
        let presenter = ProfileViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        viewController.logout()
        
        //then
        XCTAssertTrue(presenter.didTapExitButton)
        
    }
}
