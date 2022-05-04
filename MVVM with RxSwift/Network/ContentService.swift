import Foundation
import Alamofire

public class ByRequisitesDefaultResponse<T: Decodable> {
    public var success: T?
    public var error: Error?
}

class ContentService{
    
    func fetchArticles(result: @escaping (ArticlesResponse) -> Void) {
        let request = AF.request("https://saurav.tech/NewsAPI/everything/cnn.json")
        request.responseData(completionHandler: { data in
            switch data.result {
            case let .success(value):
                let decoder = JSONDecoder()
                do {
                    let out = try decoder.decode(ArticlesResponse.self, from: value)
                    print(out)
                    result(out)
                } catch {
                    print(error)
                }
            case let .failure(error):
                print(error)
            }
        })
    }

    func fetchStocks(encoding: String.Encoding, result: @escaping (String, String, [StockModel]) -> Void) {
        let delimiter = ","
        var items: [(name: String, price: String)]?
        if let url = URL(string: "https://raw.githubusercontent.com/dsancov/TestData/main/stocks.csv"),
            let content = try? String(contentsOf: url as URL, encoding: encoding) {
            items = []
            let lines:[String] = content.components(separatedBy: NSCharacterSet.newlines) as [String]
            for line in lines {
                var values:[String] = []
                if line != "" {
                    if line.range(of: "\"") != nil {
                        var textToScan:String = line
                        var value:NSString?
                        var textScanner:Scanner = Scanner(string: textToScan)
                        while textScanner.string != "" {
                            if (textScanner.string as NSString).substring(to: 1) == "\"" {
                                textScanner.scanLocation += 1
                                textScanner.scanUpTo("\"", into: &value)
                                textScanner.scanLocation += 1
                            } else {
                                textScanner.scanUpTo(delimiter, into: &value)
                            }
                            values.append(value! as String)
                            if textScanner.scanLocation < textScanner.string.count {
                                textToScan = (textScanner.string as NSString).substring(from: textScanner.scanLocation + 1)
                            } else {
                                textToScan = ""
                            }
                            textScanner = Scanner(string: textToScan)
                        }
                    } else  {
                        values = line.components(separatedBy: delimiter)
                    }
                    let item = (name: values[0], price: values[1])
                    items?.append(item)
                }
            }
        }
        guard var items = items, let headerItem = items.first(where: { $0.name == "STOCK" }),
                let headItemIndex = items.firstIndex(where: { $0.name == "STOCK" }) else { return }
        items.remove(at: headItemIndex)
        let stocks = items.map({ item -> StockModel in
            let price = Decimal(string: item.price)
            return StockModel(name: item.name, price: price)
        })
        result(headerItem.name, headerItem.price, stocks)
    }

}
