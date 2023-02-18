import UIKit


final class SplashViewController: UIViewController {
    
    private let showAuthenticationScreenSegueIdentifier = "ScreenSegueIdentifier"
    private let oAuthService = OAuth2Service.shared
    

    override func viewDidLoad() {
        super.viewDidLoad()
 }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //проверяем есть уже токен-авторизации
        if let token = oAuthService.authToken {
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

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        oAuthService.fetchOAuthToken(code) {[weak self] result in
            guard let self = self else { return }
            switch result {
            case.success:
                self.switchTabBarController()
            case .failure(let error):
                print(error.localizedDescription)
            }
            
        }
    }
    
}
    
