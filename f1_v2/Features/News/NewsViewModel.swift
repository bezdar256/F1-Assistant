import Foundation

final class NewsViewModel {
    private let service = NewsService()
    private(set) var news = FallbackData.news

    func load() async {
        if let items = try? await service.news(), !items.isEmpty {
            news = Array(items.prefix(12))
        }
    }
}
