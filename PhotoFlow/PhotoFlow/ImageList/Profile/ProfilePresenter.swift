import UIKit
import Kingfisher

protocol ProfileViewPresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    var profileService: ProfileService { get set }
    func viewDidLoad()
    func logout()
    func profileIsLoaded()
    func profileAvatarIsLoaded()
}
final class ProfileViewPresenter: ProfileViewPresenterProtocol {
    var profileService: ProfileService
    var helper: ProfileHelper
    
    init(profileService: ProfileService, helper: ProfileHelper) {
        self.profileService = profileService
        self.helper = helper
    }
    
    private var profileImageServiceObserver: NSObjectProtocol?
    var view: ProfileViewControllerProtocol?
    
    func viewDidLoad() {
        profileIsLoaded()
        profileAvatarIsLoaded()
    }
    
    func logout() {
        self.helper.cleanKeyChain()
        self.helper.switchToSplashViewController()
        self.helper.cleanWebKit()
    }
    
    func profileIsLoaded() {
        if let profile = profileService.profile {
            view?.updateProfileDetails(profile: profile)
        }
    }
    
    func profileAvatarIsLoaded() {
        profileImageServiceObserver = NotificationCenter.default.addObserver(forName: ProfileImageService.didChangeNotification, object: nil, queue: .main, using: {[weak self] _ in
            guard let self = self else { return }
            self.view?.updateAvatar()
            self.profileIsLoaded()
        })
        view?.updateAvatar()
    }
}
