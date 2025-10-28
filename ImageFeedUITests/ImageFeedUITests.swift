import XCTest

final class ImageFeedUITests: XCTestCase {
    private let app = XCUIApplication() // переменная приложения
    
    override func setUpWithError() throws { //функция выполняет запуск приложения
        continueAfterFailure = false // настройка выполнения тестов, которая прекратит выполнения тестов, если в тесте что-то пошло не так
        
        app.launch() // запускаем приложение перед каждым тестом
    }
    
    func testAuth() throws {
        // Нажать кнопку авторизации
        let authButton = app.buttons["Authenticate"]
        XCTAssertTrue(authButton.waitForExistence(timeout: 5))
        authButton.tap()
        
        // Подождать, пока экран авторизации открывается и загружается
        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 10))
     
        // Ввести данные в форму
        let loginTextField = webView.descendants(matching: .textField).element //найти поле для ввода логина
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 10))
        
        loginTextField.tap()
        XCTAssertTrue(app.keyboards.firstMatch.waitForExistence(timeout: 5))
        loginTextField.typeText("Ваш e-mail")
        
        print(app.debugDescription)
        
        func closeKeyboard() {
            if app.keyboards.buttons["Done"].exists {
                app.keyboards.buttons["Done"].tap()
            } else if app.toolbars.buttons["Done"].exists {
                app.toolbars.buttons["Done"].tap()
            } else {
                app.typeText("\n")
                if app.keyboards.firstMatch.exists {
                    app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.1)).tap()
                }
            }
        }
        
        closeKeyboard()
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element //найти поле для ввода пароля
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 10))
        
        passwordTextField.tap()
        if !app.keyboards.firstMatch.waitForExistence(timeout: 3) {
            passwordTextField.tap() // повторный тап, если клавиатура не поднялась с первого раза
        }
        XCTAssertTrue(app.keyboards.firstMatch.waitForExistence(timeout: 5))
        passwordTextField.typeText("Ваш пароль")
        
        closeKeyboard()
        
        // Нажать кнопку логина
        let loginButton = webView.buttons["Login"]
        XCTAssertTrue(loginButton.waitForExistence(timeout: 10))
        loginButton.tap()
        
        // Подождать, пока открывается экран ленты
        let tablesQuery = app.tables //таблицы на экран
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
    }
    
    func testFeed() throws {
        // тестируем сценарий ленты
    }
    
    func testProfile() throws {
        // тестируем сценарий профил
    }
}
