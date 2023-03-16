import UIKit
import Kingfisher
import SwiftKeychainWrapper
import WebKit
final class ProfileViewController: UIViewController {

    
    
//MARK: Свойства профильного экрана
    private var profilePictureView: UIImageView?
    private var fullName: UILabel?
    private var nickName: UILabel?
    private var profileDescription: UILabel?
    private var exitButton: UIButton?
    private let profileService = ProfileService.shared
    private let token = OAuth2TokenStorage().token
    private let profileImageService = ProfileImageService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeProfilePage()
        guard let profile = profileService.profile else { return }
        updateProfileDetails(profile: profile)
        profileImageServiceObserver = NotificationCenter.default.addObserver(forName: ProfileImageService.didChangeNotification, object: nil, queue: .main) { [weak self] _ in
            guard let self = self else { return }
            self.updateAvatar()
        }
        updateAvatar()
    }
    
   
    //MARK: Функции по созданию профильного экрана
    private func createProfilePicture() {
        
        let profilePicture = UIImage(named: "profilePhoto")
        let profilePictureView = UIImageView(image: profilePicture)
        self.profilePictureView = profilePictureView
        profilePictureView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(profilePictureView)
        profilePictureView.layer.cornerRadius = profilePictureView.frame.height / 2
        NSLayoutConstraint.activate([
            profilePictureView.widthAnchor.constraint(equalToConstant: 70),
            profilePictureView.heightAnchor.constraint(equalToConstant: 70),
            profilePictureView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            profilePictureView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
        ])
        
    }
    
    private func createProfileDescription() {
        
        guard let profilePictureView = profilePictureView  else { return }
        
        let fullName = UILabel()
        self.fullName = fullName
        fullName.font = .systemFont(ofSize: 23, weight: .bold)
        fullName.text = "Екатерина Новикова"
        
        fullName.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        fullName.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(fullName)
        
        let nickName = UILabel()
        self.nickName = nickName
        nickName.textColor = UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1)
        nickName.font = UIFont(name: "System Font Regular", size: 13)
        nickName.text = "@ekaterina_nov"
        nickName.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nickName)
        
        let profileDescription = UILabel()
        self.profileDescription = profileDescription
        profileDescription.textColor = UIColor.white
        profileDescription.font = UIFont(name: "System Font Regular", size: 13)
        profileDescription.text = "Hello, World!"
        profileDescription.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(profileDescription)
        
        NSLayoutConstraint.activate([
            fullName.topAnchor.constraint(equalTo: profilePictureView.bottomAnchor, constant: 8),
            fullName.leadingAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            
            nickName.leadingAnchor.constraint(equalTo: fullName.leadingAnchor),
            nickName.topAnchor.constraint(equalTo: fullName.bottomAnchor, constant: 8),
            
            profileDescription.leadingAnchor.constraint(equalTo: fullName.leadingAnchor),
            profileDescription.topAnchor.constraint(equalTo: nickName.bottomAnchor, constant: 8)
        ])
    }
    private func cleanWebKitCache() {
        // Очищаем все куки из хранилища.
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        // Запрашиваем все данные из локального хранилища.
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            // Массив полученных записей удаляем из хранилища.
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
    
    private func createExitButton() {
        
        createProfilePicture()
        guard let profilePictureView = profilePictureView else { return }
        guard let exitButtonImage = UIImage(named: "ipad.and.arrow.forward") else { return }
        let exitButton = UIButton.systemButton(with: exitButtonImage,
                                               target: self, action: .none)
        self.exitButton = exitButton
        exitButton.addTarget(self, action: #selector(logout), for: .touchUpInside)
        exitButton.tintColor = UIColor(red: 0.961, green: 0.42, blue: 0.424, alpha: 1)
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(exitButton)
        
        NSLayoutConstraint.activate([
            exitButton.widthAnchor.constraint(equalToConstant: 20),
            exitButton.heightAnchor.constraint(equalToConstant: 22),
            exitButton.centerYAnchor.constraint(equalTo: profilePictureView.centerYAnchor),
            exitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -26)
        ])
        
    }
    
    private func switchToSplashViewController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Fail to switch on SplashView")
            return
        }
        window.rootViewController = SplashViewController()
        window.makeKeyAndVisible()
    }
    
    private func cleanToken() {
        KeychainWrapper.standard.removeAllKeys()
    }
    
    @objc
    private func logout() {
        
        let alert = UIAlertController(title: "Пока-пока!",
                                      message: "Уверены что хотите выйти?",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Да", style: .default, handler: { [weak self] _ in
            self?.cleanToken()
            self?.switchToSplashViewController()
            self?.cleanWebKitCache()
        }))
        
        alert.addAction(UIAlertAction(title: "Нет", style: .cancel, handler: { _ in }))
        present(alert, animated: true)
    }
    
    
    
    private func makeProfilePage() {
        createExitButton()
        createProfileDescription()
        view.backgroundColor = UIColor(named: "black")
        
    }
}
extension ProfileViewController {
    func updateProfileDetails(profile: Profile) {
        self.profileDescription?.text = profile.bio
        self.fullName?.text = profile.name
        self.nickName?.text = profile.loginName
    }
}
extension ProfileViewController {
     func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL),
            let profilePictureView = profilePictureView else { return }
         let processor = RoundCornerImageProcessor(cornerRadius: 20)
         profilePictureView.kf.setImage(with: url, options: [.processor(processor)])
     }
}
extension ProfileViewController: AlertDelegate {
    func didRecieveAlert(_ viewController: UIAlertController) {
        present(viewController, animated: true)
    }
    
    
}
