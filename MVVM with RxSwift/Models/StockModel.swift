import Foundation
import RxDataSources

struct StockModel: Codable {
    let name: String?
    let price: Decimal?

    init(name: String?, price: Decimal?) {
        self.name = name
        self.price = price
    }
}

struct StocksViewModel {
    var header: String!
    var items: [StockModel]
}

extension StocksViewModel: SectionModelType {
    typealias Item  = StockModel

    init(original: StocksViewModel, items: [StockModel]) {
        self = original
        self.items = items
    }
}
