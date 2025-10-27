import Foundation

protocol ImagesListDateFormatterProtocol {
    func text(from date: Date?) -> String
}

final class ImagesListDateFormatter: ImagesListDateFormatterProtocol {
    private lazy var formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .long
        f.timeStyle = .none
        f.locale = Locale(identifier: "ru_RU")
        return f
    }()
    
    func text(from date: Date?) -> String {
        guard let date else { return "" }
        return formatter.string(from: date)
    }
}
