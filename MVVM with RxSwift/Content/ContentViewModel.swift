import Foundation
import RxSwift
import RxCocoa

class ContentViewModel {

    // MARK: - Private Properties
    private let contentService : ContentService
    private let disposeBag = DisposeBag()

    // MARK: - Public Properties
    var articles = Variable<[Article]>([])
    var result = Variable<ArticlesResponse?>(nil)

    var stocks = Variable<[StockModel]>([])
    var stockName = Variable<String>("")
    var stockPrice = Variable<String>("")

    var fetchArticles = PublishSubject<Void>()
    var publArts = PublishSubject<[Article]>()
    var publStocks = PublishSubject<Void>()
    var stocksLoaded = PublishSubject<[StockModel]>()

    // MARK: - Lifecycle
    init(contentService : ContentService) {
        self.contentService = contentService
        fetchArticlesData()
        fetchStock()
    }

    // MARK: - Private methods
    private func fetchArticlesData() {
        contentService.fetchArticles { [weak self] response in
            guard let self = self else { return }
            self.result = Variable(response)
            let artics: [Article] = response.articles.count > 6 ? Array(response.articles.prefix(6)) : response.articles
            self.articles = Variable(artics)
            self.fetchArticles.onNext(())
            self.publArts.onNext(self.articles.value)
        }
    }

    private func fetchStock() {
        contentService.fetchStocks(encoding: .utf8) { [weak self] header0, header1, input in
            guard let self = self else { return }
            let cut30: [StockModel] = input.count > 30 ? Array(input.prefix(30)) : input
            self.stocks = Variable(input)
            self.stockName = Variable(header0)
            self.stockPrice = Variable(header1)
            self.representStocks(cut30)
        }
    }

    private func representStocks(_ cut30: [StockModel]) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: { [weak self] in
            guard let self = self else { return }
            self.publStocks.onNext(())
            self.stocksLoaded.onNext(cut30)
            self.startUpdateStock()
        })
    }
    
    private func startUpdateStock() {
        Observable<Int>.interval(1.0, scheduler: SerialDispatchQueueScheduler(qos: .background))
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                let shuffled = self.stocks.value.shuffled()
                let cut30: [StockModel] = shuffled.count > 30 ? Array(shuffled.prefix(30)) : shuffled
                self.stocksLoaded.onNext(cut30)
            })
            .disposed(by: disposeBag)
    }
}
