import Foundation
import SwiftKeychainWrapper
final class OAuth2TokenStorage {
    
    private enum Keys: String {
        case token
    }
    
    private let keyChainWrapper = KeychainWrapper.standard
    private let key = "Auth Token"
    
    var token : String? {
        get {
            return keyChainWrapper.string(forKey: Keys.token.rawValue)
        }
        set {
            if let token = newValue {
                keyChainWrapper.set(token, forKey: Keys.token.rawValue)
            } else {
                keyChainWrapper.removeObject(forKey: Keys.token.rawValue)
            }
        }
    }
}
