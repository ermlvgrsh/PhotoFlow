import UIKit
import ProgressHUD
import SwiftKeychainWrapper

final class SplashViewController: UIViewController {
    
    private let showAuthenticationScreenSegueIdentifier = "ScreenSegueIdentifier"
    let oAuthService = OAuth2Service.shared
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private var alertProtocol: AlertProtocol?
    var tokenFlag = UserDefaults.standard.string(forKey: "tokenFlag")
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createLogo()
        checkFlag()
   }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //проверяем есть уже токен-авторизации
        alertProtocol = AlertPresenter(delegate: self)
        if let token = OAuth2TokenStorage().token {
        fetchProfile(token: token)
        } else {
            presentAuthViewController()
        }
    }

    func switchTabBarController() {
        //получаем экзмепляр 'window' приложения
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration")}
        //создаем экземпляр нужного контроллера из StoryBoard с помощью ранее созданного идентификатора
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
        .instantiateViewController(withIdentifier: "TabBarController")
        //установим в rootviewContoller полученный контроллер
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
    
    private func createLogo() {
        view.backgroundColor = UIColor(named: "black")
        let image = UIImage(named: "Vector")
        let imageView = UIImageView(image: image)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    private func getViewController(with id: String) -> UIViewController {
         
         let storyboard = UIStoryboard(name: "Main", bundle: .main)
         let viewController = storyboard.instantiateViewController(withIdentifier: id)
         return viewController
         
     }
    private func checkFlag() {
        if tokenFlag != nil {
            KeychainWrapper.standard.remove(forKey: "Auth Token")
        }
    }
    
    private func presentAuthViewController() {
    guard let authViewController = getViewController(with: "AuthViewController") as? AuthViewController
        else { fatalError()}
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true)
    }
}


extension SplashViewController: AuthViewControllerDelegate {
    
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        UIBlockingProgressHUD.show()
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.fetchOAuthToken(code: code)
       }
    }
    
    func fetchOAuthToken(code: String) {
        oAuthService.fetchOAuthToken(code) {[weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let token):
                self.fetchProfile(token: token)
                UIBlockingProgressHUD.dismiss()
            case .failure:
                self.alertProtocol?.requestAlert(title: "Что то пошло не так(", message: "Не удалось войти в систему", buttonText: "ОК")
            }
        }
    }
    private func fetchProfile(token: String) {
        profileService.fetchProfile(token) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let profile):
                ProgressHUD.show()
                self.profileImageService.fetchProfileImageURL(username: profile.username) { result in
                    switch result {
                    case.success(let avatarURL):
                        ProgressHUD.dismiss()
                        self.profileImageService.setAvatarURL(avatar: avatarURL)
                    case.failure:
                        self.alertProtocol?.requestAlert(title: "Ошибка", message: "Не удалось загрузить аватар", buttonText: "ОК")
                    }
                }
                UIBlockingProgressHUD.dismiss()
                self.switchTabBarController()
            case .failure(let error):
                self.presentAuthViewController()
                self.alertProtocol?.requestAlert(title: "Что то пошло не так(", message: "Не удалось войти в систему", buttonText: "ОК")
                print(error.localizedDescription)
            }
        }
    }
}

    
extension SplashViewController: AlertDelegate {
    func didRecieveAlert(_ alertController: UIAlertController) {
        present(alertController, animated: true)
    }
}
