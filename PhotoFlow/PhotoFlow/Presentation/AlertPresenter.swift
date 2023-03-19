import UIKit

protocol AlertProtocol {
    func requestAlert(title: String, message: String, buttonText: String)
}

protocol AlertDelegate: AnyObject {
    func didRecieveAlert(_ viewController: UIAlertController)
}

struct AlertPresenter: AlertProtocol {
    
    weak var delegate : AlertDelegate?
    
    func requestAlert(title: String, message: String, buttonText: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: buttonText, style: .default)
        alert.addAction(action)
        delegate?.didRecieveAlert(alert)
    }
}
