import Foundation
import SwiftKeychainWrapper
final class OAuth2TokenStorage {
    
    private enum Keys: String {
        case token
    }
    
    private let keyChainWrapper = KeychainWrapper.standard
    private let key = "Auth Token"
    var flag: Bool?
    var token : String? {
        get {
            return keyChainWrapper.string(forKey: Keys.token.rawValue)
        }
        set {
            if let token = newValue {
                flag = true
                UserDefaults.standard.set(flag, forKey: "tokenFlag")
                keyChainWrapper.set(token, forKey: Keys.token.rawValue)
            }
        }
    }
}
