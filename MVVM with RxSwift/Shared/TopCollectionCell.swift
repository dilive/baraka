import UIKit
import RxSwift
import RxCocoa

class TopCollectioCell: UICollectionViewCell {

    // MARK: - Outlets

    @IBOutlet weak var cellImageView: UIImageView!
    @IBOutlet weak var cellTopLabel : UILabel!
    @IBOutlet weak var cellBottomLabel : UILabel!
    @IBOutlet weak var cellDescriptionTextView : UITextView!

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        setup()
    }

    // MARK: - Private methods

    private func setup() {
        layer.cornerRadius = 10
        layer.masksToBounds = true
    }
}
