import Foundation
import UIKit
import Kingfisher

protocol ProfileViewPresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func logout()
    func profileIsLoaded()
    func profileAvatarIsLoaded()
}

final class ProfileViewPresenter: ProfileViewPresenterProtocol {
    var profileImageServiceObserver: NSObjectProtocol?
    weak var view: ProfileViewControllerProtocol?
    var profileService = ProfileService.shared
    var profileImageService = ProfileImageService.shared
    var profileHelper: ProfileHelperProtocol?
    
    
    func profileAvatarIsLoaded() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL) else { return }
        
        KingfisherManager.shared.retrieveImage(with: url) { result in
            switch result {
            case.success(let avatarImage):
                self.updateAvatarImage(avatarImage.image)
            case.failure(let error):
                assertionFailure(error.localizedDescription)
            }
        }
        
    }
    
    func updateAvatarImage(_ image: UIImage) {
        view?.didUpdateAvatar(image: image)
    }
    
    func viewDidLoad() {
        observeProfileImage()
    }
    
    func observeProfileImage() {
        profileImageServiceObserver = NotificationCenter.default.addObserver(forName: ProfileImageService.didChangeNotification, object: nil, queue: .main) { [weak self] _ in
            guard let self = self else { return }
            self.profileAvatarIsLoaded()
        }
    }
    
    func profileIsLoaded() {
        guard let profile = profileService.profile else { return }
        profileFromView(profile: profile)
    }
    
    func profileFromView(profile: Profile) {
        view?.didFetchProfile(profile: profile)
    }
    
    func logout() {
        let alert = UIAlertController(title: "Пока-пока!",
                                      message: "Уверены что хотите выйти?",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Да", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            self.profileHelper?.cleanKeyChain()
            self.profileHelper?.switchToSplashViewController()
            self.profileHelper?.cleanWebKit()
        }))
        alert.addAction(UIAlertAction(title: "Нет", style: .default, handler: { _ in }))
        view?.present(alert: alert)
        
    }
    
}
