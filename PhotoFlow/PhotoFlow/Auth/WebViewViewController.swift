import WebKit
import UIKit

public protocol WebViewControllerProtocol: AnyObject {
    var presenter: WebViewPresenterProtocol? { get set }
    func load(request: URLRequest)
    func setProgressValue(_ newValue: Float)
    func setProgressHidden(_ isHidden: Bool)
}


//MARK: Delegate WebViewViewController

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

//создаем класс, который отображает страницу логина
final class WebViewViewController: UIViewController & WebViewControllerProtocol {
    
    //MARK: Свойства экрана WebView
    
    var presenter: WebViewPresenterProtocol?
    weak var delegate : WebViewViewControllerDelegate?          //инъектируем делегат, для использования методов
    private var webView : WKWebView?                                    //переменная отображающая класс WKWebView
    private var backButton: UIButton?                                       //переменная кнопка назад
    private var progress: UIProgressView?
    private var estimatedProgressObservation: NSKeyValueObservation?
    //MARK: Lifecycle WebViewViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createWebView()

    }
    

    
    //MARK: Функции для создания UIElements
    
    
    func load(request: URLRequest) {
        guard let webView = webView else { return }
        webView.load(request)
    }
    private func createProgressView() {
        let progressTab = UIProgressView()
        progressTab.progressTintColor = UIColor.black
        
        self.progress = progressTab
        progressTab.progress = 0.05
        
        view.addSubview(progressTab)
        progressTab.translatesAutoresizingMaskIntoConstraints = false
        
        guard let backButton = backButton else { return }
        
        NSLayoutConstraint.activate(
            [
                progressTab.topAnchor.constraint(equalTo: backButton.bottomAnchor),
                progressTab.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                progressTab.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ]
        )
   }
    
    private func createWebView() {                              //метод отображающий нашу страницу авторизации
        
        let webView = WKWebView()                               //создаем экземпляр класс ВебВью
        self.webView = webView                    // присваиваем экземпляр класса к экземпляру метода
        view.addSubview(webView)                  //добавляем на вью наш вэбвью
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        webView.frame = view.bounds
      
        createButton()
        createProgressView()
        guard let presenter = presenter else { return }
        presenter.viewDidLoad()
        webView.navigationDelegate = self         //делаем WebViewViewController навигационным делегатом для вэбвью
    }
    
    private func createButton()  {                                                   //создаем кнопку
        
        let imageButton = UIImage(named: "chevron.backward")                    //создаем картинку для кнопки
        guard let imageButton = imageButton  else { return }                    //разворачиваем
        
        let button = UIButton(type: .system)                                    //создаем экземпляр кнопки
        self.backButton = button                                              //присваиваем кнопке класс наш экземпляр
        
        button.setImage(imageButton, for: .normal)                          //устанавливаем картинку для кнопки
        button.addTarget(self, action: #selector(buttonBackTapped), for: .touchUpInside)
        button.setBackgroundImage(UIImage(), for: .normal)
        button.tintColor = UIColor.black
        
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        
        button.heightAnchor.constraint(equalToConstant: 16).isActive = true
        button.widthAnchor.constraint(equalToConstant: 9).isActive = true
        button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        button.topAnchor.constraint(equalTo: view.topAnchor, constant: 59).isActive = true
        button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -350).isActive = true
        button.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -737).isActive = true
        
    }
    @objc func buttonBackTapped(_ sender: UIButton) {             //метод при нажатии кнопки назад
        delegate?.webViewViewControllerDidCancel(self)
    }
    
    func setProgressValue(_ newValue: Float) {
        progress?.progress = newValue
    }
    func setProgressHidden(_ isHidden: Bool) {
        progress?.isHidden = isHidden
    }

}

//MARK: Extension WebViewViewController
extension WebViewViewController: WKNavigationDelegate {                     // расширение для  вебвью при успеш. автор.
    
    func webView(                                       //метод пользователь  выполняет какие-то навигационые действия
        _ webView: WKWebView,                                       // первый параметр - сам вэбвью
        decidePolicyFor navigationAction: WKNavigationAction, // второй - объект содержащий инф. о причине навиг. действ.
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void   //третий замыкание хэндлер, принимающий 1 из 3 знач
    ) {
        if let code = code(from: navigationAction) { //вызываем метод code возвращающая код авторизации если он получен
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)            //отменяем навигационное действие
        } else {
            decisionHandler(.allow)             // возможный переход на новую страницу при авторизации
        }
    }
    
    private func code(from navigationAction: WKNavigationAction) -> String? { //метод возвращения кода авторизации
        if let url = navigationAction.request.url {
            return presenter?.code(from: url) //получаем из навигационного действия URL в презентере
        }
        return nil
    }
}



