import Foundation
import UIKit


class SplashViewController: UIViewController {
    
    let showAuthenticationScreenSegueIdentifier = "AuthenticationScreenSegueIdentifier"
    let oAuthToken = OAuth2TokenStorage().token
    let networkRouter = OAuth2Service()
    
    override func viewDidLoad() {
         super.viewDidLoad()
            createLogo()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       
        if let token = oAuthToken {
            switchTabBarController()
        } else {
            
            performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
        }
    }
    func switchTabBarController() {
        // получаем экземпляр window приложения
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration")}
        // создаем экземпляр нужного контроллера из Storyboard с помощью заранее созданного идентификатора
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        //устанавливаем в rootController полученный контроллер
            window.rootViewController = tabBarController
    }
}

extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showAuthenticationScreenSegueIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers[0] as? AuthViewController
            else { fatalError("Fail to prepare for \(showAuthenticationScreenSegueIdentifier)") }
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
        networkRouter.fetchOAuthToken(code) {[weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(_):
                self.switchTabBarController()
            case .failure(_):
                break
            }
        }
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
