import XCTest

final class PhotoFlowUITests: XCTestCase {

    let app = XCUIApplication()
    
    override func setUpWithError() throws {
       continueAfterFailure = false
        
        app.launch()
    }

    func testAuth() throws {
        // Нажать кнопку авторизации
        app.buttons["Войти"].tap()

        
        // Ввести данные в форму
        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 5))
        // Подождать, пока экран авторизации открывается и загружается
        sleep(7)
        let loginTextField = webView.descendants(matching: .textField).element
        
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        loginTextField.tap()
        loginTextField.typeText("test")
        app.toolbars.buttons["Done"].tap()
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        passwordTextField.tap()
        passwordTextField.typeText("test")
        app.toolbars.buttons["Done"].tap()
        // Нажать кнопку логина
        let loginButton = webView.descendants(matching: .button).element
        loginButton.tap()
        // Подождать, пока открывается экран ленты
        sleep(15)
        
        let tables = app.tables
        let cell = tables.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
        
        
    }

    func testFlow() throws {
        // Подождать, пока открывается и загружается экран ленты
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        // Сделать жест «смахивания» вверх по экрану для его скролла
        cell.swipeUp()
        sleep(5)
        // Поставить лайк в ячейке верхней картинки
        let cellLikeButton = tablesQuery.children(matching: .cell).element(boundBy: 1)
        
        cellLikeButton.buttons["likeButton"].tap()
        sleep(5)
        cellLikeButton.buttons["likeButton"].tap()
        
        sleep(5)
        // Отменить лайк в ячейке верхней картинки
        cellLikeButton.tap()
        sleep(5)
        
        let image = app.scrollViews.images.element(boundBy: 0)
        sleep(10)
        
        image.pinch(withScale: 3, velocity: 1)
        image.pinch(withScale: 0.5, velocity: -1)
        let navButton = app.buttons["navBackButton"]
        navButton.tap()

        XCTAssertTrue(cell.waitForExistence(timeout: 5))
        
        
    }


    func testProfile() throws {
        sleep(5)
        
        app.tabBars.buttons.element(boundBy: 1).tap()
        
        sleep(2)
        
        XCTAssertTrue(app.staticTexts["Grigoriy Ermolaev"].exists)
        XCTAssertTrue(app.staticTexts["@ermlvgrsh"].exists)
        sleep(2)
        let exitButton = app.buttons["ipad.and.arrow"]
        sleep(2)
        exitButton.tap()
        sleep(2)
        
        app.alerts["Пока-пока!"].scrollViews.otherElements.buttons["Да"].tap()
    }
}
