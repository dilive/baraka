import Foundation
import RxDataSources

struct ArticlesResponse: Codable {
    let status : String
    let totalResults : Int
    let articles: [Article]

    enum CodingKeys: String, CodingKey {
        case status
        case totalResults
        case articles
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        status = try container.decode(String.self, forKey: .status)
        totalResults = try container.decode(Int.self, forKey: .totalResults)
        articles = try container.decode([Article].self, forKey: .articles)
    }
}

struct Article: Codable {
    let source: [Sourse]?
    let author: String?
    let title: String?
    let description: String?
    let url: String?
    let urlToImage: String?
    let publishedAt: String?
    let content: String?

    enum CodingKeys: String, CodingKey {
        case source
        case author
        case title
        case description
        case url
        case urlToImage
        case publishedAt
        case content
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        source = try? container.decode([Sourse].self, forKey: .source)
        author = try? container.decode(String.self, forKey: .author)
        title = try? container.decode(String.self, forKey: .title)
        description = try? container.decode(String.self, forKey: .description)
        url = try? container.decode(String.self, forKey: .url)
        urlToImage = try? container.decode(String.self, forKey: .urlToImage)
        publishedAt = try? container.decode(String.self, forKey: .publishedAt)
        content = try? container.decode(String.self, forKey: .content)
    }
}

struct Sourse: Codable {
    let id: String
    let name: String
}

struct ArticleViewModel {
    var header: String!
    var items: [Article]
}

extension ArticleViewModel: SectionModelType {
    typealias Item  = Article
    init(original: ArticleViewModel, items: [Article]) {
        self = original
        self.items = items
    }
}
