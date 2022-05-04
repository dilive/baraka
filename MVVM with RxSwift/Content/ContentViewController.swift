import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import Alamofire

class ContentViewController: UIViewController, UICollectionViewDelegate {

    // MARK: - Constants
    private enum Constants {
        static let nonBreak = "\u{00a0}"
    }

    // MARK: - Outlets

    @IBOutlet weak var topLabel : UILabel!
    @IBOutlet weak var topCollectionView : UICollectionView!
    @IBOutlet weak var stocksCollectionView : UICollectionView!
    @IBOutlet weak var bottomCollectionView : UICollectionView!
    @IBOutlet weak var stockNameLabel : UILabel!
    @IBOutlet weak var stockProceLabel : UILabel!

    // MARK: - Private Properties

    private let viewModel = ContentViewModel(contentService: ContentService())
    private let disposeBag = DisposeBag()

    private var loadingView: UIView = {
        let loadingView = UIView()
        loadingView.backgroundColor = .white.withAlphaComponent(0.7)
        loadingView.isHidden = false
        return loadingView
    }()

    private lazy var topFlowLayout: UICollectionViewFlowLayout = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumInteritemSpacing = 0.0
        flowLayout.sectionInset = UIEdgeInsets(top: 0.0, left: 16.0, bottom: 0.0, right: 16.0)
        flowLayout.itemSize = CGSize(width: UIScreen.main.bounds.width - 48.0,
                                     height: 140.0)
        return flowLayout
    }()

    private lazy var stockFlowLayout: UICollectionViewFlowLayout = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumInteritemSpacing = 0.0
        flowLayout.sectionInset = UIEdgeInsets(top: 0.0, left: 16.0, bottom: 0.0, right: 16.0)
        flowLayout.itemSize = CGSize(width: 128.0,
                                     height: 78.0)
        return flowLayout
    }()

    private lazy var newsFlowLayout: UICollectionViewFlowLayout = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumInteritemSpacing = 0.0
        flowLayout.sectionInset = .zero
        flowLayout.estimatedItemSize = UICollectionViewFlowLayoutAutomaticSize
        return flowLayout
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModelBindings()
    }

    // MARK: - Private methods

    private func viewModelBindings(){
        setupCollectionView()
        setupCollectionViewLayout()
        bindStates()
        addLoadingView()
    }

    private func setupCollectionView() {
        topCollectionView.showsHorizontalScrollIndicator = false
        topCollectionView.backgroundColor = .clear
        topCollectionView.isPagingEnabled = false
        stocksCollectionView.backgroundColor = .clear
    }

    private func setupCollectionViewLayout() {
        topCollectionView.collectionViewLayout = topFlowLayout
        stocksCollectionView.collectionViewLayout = stockFlowLayout
        bottomCollectionView.collectionViewLayout = newsFlowLayout
    }

    private func bindStates() {
        setupTopCollection()
        setupStocksCollection()
        setupBottomCollection()
        let combineLoads = Observable.merge(viewModel.publArts.map { _ in return Void() }, viewModel.publStocks.map { _ in return Void() })
        combineLoads
            .delay(RxTimeInterval(1), scheduler: MainScheduler.instance)
            .bind(onNext: { [weak self] in
                guard let self = self else { return }
                self.loadingView.isHidden = true
            })
            .disposed(by: disposeBag)
        
        viewModel.fetchArticles
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.topLabel.text = "Articles"
            })
            .disposed(by: disposeBag)

        viewModel.publStocks
            .bind(onNext: { [weak self] in
                guard let self = self else { return }
                self.stockNameLabel.text = self.viewModel.stockName.value + " /"
                self.stockProceLabel.text = self.viewModel.stockPrice.value
            })
            .disposed(by: disposeBag)
    }

    private func setupTopCollection() {
        let dataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<String, Article>>(configureCell: { (source, collectionView, indexPath, article) in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TopCollectioCell", for: indexPath) as! TopCollectioCell
            cell.cellTopLabel.text = article.title
            cell.cellBottomLabel.text = article.author
            cell.cellDescriptionTextView.text = article.description
            if let urlToImage = article.urlToImage, let url = URL(string: urlToImage) {
                DispatchQueue.global(qos: .userInitiated).async {
                    do {
                        let imageData: Data = try Data(contentsOf: url)
                        DispatchQueue.main.async {
                            let image = UIImage(data: imageData)
                            cell.cellImageView.image = image
                        }
                    } catch {
                        print("Unable to show data: \(error)")
                    }
                }
            }
            return cell
        })
        viewModel.publArts
            .map {(articles) -> [SectionModel<String, Article>] in
                return [SectionModel(model: "", items: articles)]
            }
            .bind(to: topCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }

    private func setupStocksCollection() {
        let dataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<String, StockModel>>(configureCell: { [weak self] (source, collectionView, indexPath, stock) in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StockCollectioCell", for: indexPath) as! StockCollectioCell
            cell.nameLabel.text = stock.name
            guard let self = self else {
                return cell
            }
            cell.priceLabel.text = self.fetchNumberTwoFractions(stock.price)
            return cell
        })
        viewModel.stocksLoaded
            .map { (stocks) -> [SectionModel<String, StockModel>] in
                return [SectionModel(model: "", items: stocks)]
            }
            .bind(to: stocksCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }

    private func setupBottomCollection() {
        let dataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<String, Article>>(configureCell: { (source, collectionView, indexPath, article) in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewsCollectioCell", for: indexPath) as! NewsCollectioCell
            cell.topLabel.text = article.title
            cell.bottomLabel.text = self.formatDate(article.publishedAt)
            cell.mainText.text = article.description
            if let urlToImage = article.urlToImage, let url = URL(string: urlToImage) {
                DispatchQueue.global(qos: .userInitiated).async {
                    do {
                        let imageData: Data = try Data(contentsOf: url)
                        DispatchQueue.main.async {
                            let image = UIImage(data: imageData)
                            cell.imageView.image = image
                        }
                    } catch {
                        print("Unable to show data: \(error)")
                    }
                }
            }
            return cell
        })
        viewModel.publArts
            .map {(articles) -> [SectionModel<String, Article>] in
                return [SectionModel(model: "", items: articles)]
            }
            .bind(to: bottomCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }

    private func fetchNumberTwoFractions(_ value: Decimal?) -> String {
        guard let value = value else {
            return ""
        }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return (formatter.string(from: value as NSDecimalNumber)?
            .replacingOccurrences(of: Constants.nonBreak, with: "")
            .replacingOccurrences(of: ",", with: ".")
            .replacingOccurrences(of: " ", with: "") ?? "") + " USD"
    }

    private func formatDate(_ dateString: String?) -> String? {
        guard let dateString = dateString else { return nil }
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        guard let date = dateFormatter.date(from: dateString) else { return nil }
        let outFormatter = DateFormatter()
        outFormatter.dateFormat = "dd MMM yyyy, HH:mm"
        return outFormatter.string(from: date)
    }

    private func addLoadingView() {
        self.view.addSubview(loadingView)
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loadingView.topAnchor.constraint(equalTo: self.view.topAnchor),
            loadingView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            loadingView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
}
