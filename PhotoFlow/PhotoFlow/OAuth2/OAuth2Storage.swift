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
            return keyChainWrapper.string(forKey: key)
        }
        set {
            guard let token = newValue else { return }
            keyChainWrapper.set(token, forKey: key)
        }
    }
}
