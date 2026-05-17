import UIKit
import SnapKit

extension UIView {
    var safeTop: ConstraintItem { safeAreaLayoutGuide.snp.top }
    var safeBottom: ConstraintItem { safeAreaLayoutGuide.snp.bottom }
}
