import UIKit


final class SplashViewController: UIViewController {
    
    private let showAuthenticationScreenSegueIdentifier = "ScreenSegueIdentifier"
    let oAuthService = OAuth2Service.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        createLogo()
 }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //проверяем есть уже токен-авторизации
        if let token = oAuthService.authToken {
            switchTabBarController()
        } else {
            performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
        }
    }

    
    func switchTabBarController() {
        //получаем экзмепляр 'window' приложения
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration")}
        //создаем экземпляр нужного контроллера из StoryBoard с помощью ранее созданного идентификатора
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
        .instantiateViewController(withIdentifier: "TabBarViewController")
        //установим в rootviewContoller полученный контроллер
        window.rootViewController = tabBarController
        
    }
    
    private func createLogo() {
        let image = UIImage(named: "Vector")
        let imageView = UIImageView(image: image)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
}
extension SplashViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == showAuthenticationScreenSegueIdentifier {
           guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers[0] as? AuthViewController
            else {
                fatalError("Failed to prepare for \(showAuthenticationScreenSegueIdentifier)")
            }
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}



extension SplashViewController: AuthViewControllerDelegate {
    
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.fetchOAuthToken(code: code)
        }
    }
    func fetchOAuthToken(code: String) {
        oAuthService.fetchOAuthToken(code) {[weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(_):
                self.switchTabBarController()
            case .failure(_):
                break
            }
        }
    }
}

    
