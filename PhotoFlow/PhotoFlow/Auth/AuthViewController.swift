import UIKit
protocol AuthViewControllerDelegate: AnyObject {
    func authViewController (_ vc: AuthViewController, didAuthenticateWithCode code: String)
}

final class AuthViewController: UIViewController {

    var webViewViewIdentifier = "ShowWebView"
    private var imageView: UIImageView?
    private var button: UIButton?
    var networkDelegate : NetworkRouting?
    var delegate: AuthViewControllerDelegate?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == webViewViewIdentifier {
            guard
                let webViewController = segue.destination as? WebViewViewController
            else { fatalError("Error!") }
                webViewController.delegate = self
            } else {
           super.prepare(for: segue, sender: sender)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        createEnterView()
        
    }
   
}
extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        delegate?.authViewController(self, didAuthenticateWithCode: code)
   }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }
    private func createLogo() {
        let logo = UIImage(named: "unsplashLogo")
        let imageView = UIImageView(image: logo)
       
        self.imageView = imageView
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        
        view.addSubview(imageView)
        imageView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
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
            .font: UIFont.systemFont(ofSize: 17) ]
        

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
    
    @objc func enterButtonPressed() {
        let webView = WebViewViewController()
        webView.modalPresentationStyle = .fullScreen
        self.present(webView, animated: true)
   
    }
    
    private func createEnterView() {
        createLogo()
        createButton()
    }
    
    
}


