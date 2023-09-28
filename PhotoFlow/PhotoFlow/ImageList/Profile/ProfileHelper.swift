import Foundation
import SwiftKeychainWrapper
import WebKit

protocol ProfileHelperProtocol {
    func cleanKeyChain()
    func cleanWebKit()
    func switchToSplashViewController()
}
struct ProfileHelper: ProfileHelperProtocol {
    func switchToSplashViewController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Fail to switch on SplashView")
            return
        }
        window.rootViewController = SplashViewController()
        window.makeKeyAndVisible()
        
    }
    
    func cleanKeyChain() {
        KeychainWrapper.standard.removeAllKeys()
    }
    
    func cleanWebKit() {
        // Очищаем все куки из хранилища.
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        // Запрашиваем все данные из локального хранилища.
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            // Массив полученных записей удаляем из хранилища.
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
}
