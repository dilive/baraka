import UIKit
import RxSwift
import RxCocoa

class NewsCollectioCell: UICollectionViewCell {

    // MARK: - Outlets

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var topLabel : UILabel!
    @IBOutlet weak var bottomLabel : UILabel!
    @IBOutlet weak var mainText : UILabel!

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
