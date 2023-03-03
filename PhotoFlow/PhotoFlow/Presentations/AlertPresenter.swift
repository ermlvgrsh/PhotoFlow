import UIKit

struct AlertPresenter: AlertProtocol {
    weak var viewController: UIViewController?
    init(viewController: UIViewController?) {
        self.viewController = viewController
    }
    func show(warning: AlertModel) {
        let alert = UIAlertController(title: warning.title,
                                      message: warning.message,
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: warning.buttonText,
                                   style: .default,
                                   handler: {_ in
            warning.completion()
            
        }
        )

        alert.addAction(action) // добавляем
        viewController?.present(alert, animated: true, completion: nil)
        
    }
    
}
