import XCTest

final class ImageFeedUITests: XCTestCase {
    private let app = XCUIApplication() // переменная приложения
    
    override func setUpWithError() throws { //функция выполняет запуск приложения
        continueAfterFailure = false // настройка выполнения тестов, которая прекратит выполнения тестов, если в тесте что-то пошло не так
        
        app.launchArguments += ["-uiTesting"]
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
        let loginTextField = webView.descendants(matching: .textField).element
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
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
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
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
    }
    
    func testFeed() throws {
        // Подождать, пока открывается и загружается экран ленты
        let tablesQuery = app.tables
        
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        
        // Сделать жест «смахивания» вверх по экрану для его скролла
        cell.swipeUp()
        
        sleep(2)
        
        // Поставить лайк в ячейке верхней картинки
        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1)
        
        XCTAssertTrue(cellToLike.buttons["like_button"].waitForExistence(timeout: 5))
        cellToLike.buttons["like_button"].tap()
        
        sleep(3)
        
        // Отменить лайк в ячейке верхней картинки
        XCTAssertTrue(cellToLike.buttons["like_button"].waitForExistence(timeout: 5))
        cellToLike.buttons["like_button"].tap()
        
        sleep(2)
        
        // Нажать на верхнюю ячейку
        cellToLike.tap()
        
        // Подождать, пока картинка открывается на весь экран
        sleep(2)
            
        let image = app.scrollViews.images.element(boundBy: 0)
        
        // Увеличить картинку
        image.pinch(withScale: 3, velocity: 1)
        
        // Уменьшить картинку
        image.pinch(withScale: 0.5, velocity: -1)
        
        // Вернуться на экран ленты
        let backButton = app.buttons["backButton"]
        XCTAssertTrue(backButton.waitForExistence(timeout: 5))
        backButton.tap()
    }
    
    func testProfile() throws {
        // тестируем сценарий профил
    }
}
