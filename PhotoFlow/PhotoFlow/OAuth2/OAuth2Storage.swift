import Foundation
//создаем класс для хранения токена, который получаем при авторизации
class OAuth2TokenStorage {
    
    private enum Keys: String {
        case token
    }
    let userDefaults = UserDefaults.standard
    
    
    var token: String? {
        get {
            guard let code = userDefaults.string(forKey: Keys.token.rawValue) else { return nil }
             //получаем значение через свойство класса для хранения токена
            return code
        }
        set {
            if let token = newValue {userDefaults.set(newValue, forKey: Keys.token.rawValue) //устанавливаем новое значение при обновлении
            } else {
                userDefaults.removeObject(forKey: Keys.token.rawValue)
            }
        }
    }
}
