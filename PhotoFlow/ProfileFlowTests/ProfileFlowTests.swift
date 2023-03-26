@testable import PhotoFlow
import XCTest
import UIKit


final class ProfileViewPresenterSpy: ProfileViewPresenterProtocol {
    var view: PhotoFlow.ProfileViewControllerProtocol?
    var profileService: PhotoFlow.ProfileService = PhotoFlow.ProfileService()
    var viewDidLoaded = false
    
    func viewDidLoad() {
        viewDidLoaded = true
    }
    
    func logout() { }
    
    func profileIsLoaded() { }
    
    func profileAvatarIsLoaded() { }
    
}

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var presenter: PhotoFlow.ProfileViewPresenterProtocol?
    var updatedProfileDetails = false
    var updatedAvatar = false
    func updateProfileDetails(profile: PhotoFlow.Profile) {
        updatedProfileDetails = true
    }
    
    func updateAvatar() {
        updatedAvatar = true
    }
}

final class ProfileServiceDummy: ProfileServiceProtocol {
    func convert(from result: PhotoFlow.ProfileResult) -> PhotoFlow.Profile {
        let profile = Profile(username: result.username,
                              name: "\(result.firstName) \(result.lastName)",
                              loginName: "@\(result.username)",
                              bio: result.bio)
        return profile
    }
    
    var profile: PhotoFlow.Profile?
    
    func fetchProfile(_ token: String, completion: @escaping (Result<PhotoFlow.Profile, Error>) -> Void) {
    let profileResult = ProfileResult(username: "test", firstName: "for", lastName: "profile", bio: "")
        let converter = convert(from: profileResult)
        completion(.success(converter))
    }
}

final class ProfileImageServiceDummy: ProfileImageServiceProtocol {
    var avatarURL: String?
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) { }
}


final class ProfileViewTests: XCTestCase {
    
    func testViewDidLoad() {
        let viewController = ProfileViewController()
        let presenter = ProfileViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController

        _ = viewController.view

        XCTAssertTrue(presenter.viewDidLoaded)
    }
    
    func testUpdateProfileDetails() {
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfileViewPresenter(profileService: ProfileService(), helper: ProfileHelper())
        
        viewController.presenter = presenter
        presenter.view = viewController
        
        let profileServiceDummy = ProfileServiceDummy()
        let profileImageServiceDummy = ProfileImageServiceDummy()
        
        
        profileServiceDummy.fetchProfile("") { result in
            switch result {
            case.success:
                profileImageServiceDummy.fetchProfileImageURL(username: "") { _ in
                    presenter.viewDidLoad()
                    XCTAssertTrue(viewController.updatedProfileDetails)
                    XCTAssertTrue(viewController.updatedAvatar)
                }
            case.failure:
                XCTFail()
            }
        }
    }
}
