import UIKit
import RxSwift
import RxCocoa

class StockCollectioCell: UICollectionViewCell {

    // MARK: - Outlets

    @IBOutlet weak var nameLabel : UILabel!
    @IBOutlet weak var priceLabel : UILabel!

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: .zero)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }
}
