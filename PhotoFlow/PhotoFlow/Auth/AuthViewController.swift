import UIKit
protocol AuthViewControllerDelegate: AnyObject {
    func authViewController (_ vc: AuthViewController, didAuthenticateWithCode code: String)
}

final class AuthViewController: UIViewController {
    
    private var webViewViewIdentifier = "ShowWebView"
    private var imageView: UIImageView?
    private var button: UIButton?
    weak var delegate: AuthViewControllerDelegate?
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createEnterView()
    }
    
    private func createLogo() {
        let logo = UIImage(named: "unsplashLogo")
        let imageView = UIImageView(image: logo)
        
        self.imageView = imageView
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 60),
            imageView.widthAnchor.constraint(equalToConstant: 60),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    private func createButton() {
        
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.tintColor = .black
        button.layer.masksToBounds = true
        button.setTitleColor(.black,
                             for: .normal)
        button.layer.cornerRadius = 16
     
        button.addTarget(self,
                         action: #selector(enterButtonPressed),
                         for: .touchUpInside)
        createLogo()
        guard let imageView = imageView else { return }
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let titleAttribute: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 17, weight: .bold)  ]
        
        
        let titleAttributedString = NSAttributedString(string: "Войти", attributes: titleAttribute)
        button.setAttributedTitle(titleAttributedString, for: .normal)
        button.addTarget(self, action: #selector(enterButtonPressed), for: .touchUpInside)
        
        view.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 204),
            button.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            button.heightAnchor.constraint(equalToConstant: 48),
            button.widthAnchor.constraint(equalToConstant: 343)])
        
    }
    @objc private func enterButtonPressed() {
        didLoadWebView()
        
    }
    private func createEnterView() {
        createLogo()
        createButton()
    }
    
    func didLoadWebView() {
        let webView = WebViewViewController()
        webView.delegate = self
        webView.modalPresentationStyle = .fullScreen
        self.present(webView, animated: true)
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }
    
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        delegate?.authViewController(self, didAuthenticateWithCode: code)
    }
}
