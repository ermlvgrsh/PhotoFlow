import UIKit


final class SplashViewController: UIViewController {
 
    let showAuthenticationScreenSegueIdentifier = "ScreenSegueIdentifier"
    let oAuthService = OAuth2Service()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}


extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showAuthenticationScreenSegueIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers[0] as? AuthViewController
            else {
                fatalError("Fail to prepare \(showAuthenticationScreenSegueIdentifier)")
            }
            viewController.delegate = self
        }
        super.prepare(for: segue, sender: sender)
    }
}
extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        switchTabBarController()
    }
}
