import UIKit

protocol AlertProtocol {
    func requestAlert()
}

protocol AlertDelegate: AnyObject {
    func didRecieveAlert(_ viewController: UIAlertController)
}

struct AlertPresenter: AlertProtocol {
    
    weak var delegate : AlertDelegate?
    
    func requestAlert() {
        let title = "Что-то пошло не так("
        let message = "Не удалось войти в систему"
        let buttonText = "OK"
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: buttonText, style: .default)
        alert.addAction(action)
        delegate?.didRecieveAlert(alert)
        
    }
}
