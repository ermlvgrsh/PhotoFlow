import WebKit
import UIKit

//MARK: Delegate WebViewViewController

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

//создаем класс, который отображает страницу логина
final class WebViewViewController: UIViewController {
    
    //MARK: Свойства экрана WebView
    
    weak var delegate : WebViewViewControllerDelegate?          //инъектируем делегат, для использования методов
    private var webView : WKWebView?                                    //переменная отображающая класс WKWebView
    private var backButton: UIButton?                                       //переменная кнопка назад
    private var progress: UIProgressView?
    private var service = OAuth2Service.shared
    

    //MARK: Lifecycle WebViewViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createWebView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let webView = webView else { return }
        webView.addObserver(self,
                            forKeyPath: #keyPath(WKWebView.estimatedProgress),
                            options: .new,
                            context: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let webView = webView else { return }
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), context: nil)
    }
    
    //MARK: Функции для создания UIElements
    
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
        
        let constant = Constants()                             // создаем эземпляр структуры для использования данных
        let urlComponents = URLComponents(string: constant.unsplashAuthorizeString) //инициализируем структуру, указываем адрес
        guard var urlComponents = urlComponents else { return }   //разворачиваем ее, для дальнейшего использования
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: constant.accessKey), //устанаваливаем значение - код доступа
            URLQueryItem(name: "redirect_uri", value: constant.redirectUri), //значение URI - обработку успеш. автор.
            URLQueryItem(name: "response_type", value: "code"),             //тип ответа который мы ожидаем - code
            URLQueryItem(name: "scope", value: constant.accessScope)        //список доступов, разделенных доступом
        ]
        guard let url = urlComponents.url else { return }       //разворачиваем получившийся URL
        let request = URLRequest(url: url)                      //формируем URL запрос
        createButton()
        createProgressView()
        webView.load(request)
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
    
    private func updateProgress() {
        guard let progress = progress else { return }
        guard let webView = webView else { return }
        progress.progress = Float(webView.estimatedProgress)
        progress.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
    }
    
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(WKWebView.estimatedProgress) {
            updateProgress()
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
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
            service.fetchOAuthToken(code) { result in
                switch result {
                case .success(_):
                    self.delegate?.webViewViewController(self, didAuthenticateWithCode: code)
                case .failure(let error):
                    print("error \(error.localizedDescription)")
               }
            }
           decisionHandler(.cancel)            //отменяем навигационное действие
        } else {
            decisionHandler(.allow)             // возможный переход на новую страницу при авторизации
        }
    }
}

private func code(from navigationAction: WKNavigationAction) -> String? { //метод возвращения кода авторизации
    if
        let url = navigationAction.request.url,         //получаем из навигационного действия URL
        let urlComponents = URLComponents(string: url.absoluteString), //создаем структуру получаем значения компо
        urlComponents.path == "/oauth/authorize/native", //проверяем совпадает ли адрес запрос с адресом получ.кода
        let items = urlComponents.queryItems,    //проверяем есть ли в URLC компоненты запроса
        let codeItems = items.first(where: {$0.name == "code"}) //ищем в массиве компонентов элемент с именем code
    {
        return codeItems.value      //если проверки прошли успешно вернуть значение
    } else {
        return nil
    }
}
