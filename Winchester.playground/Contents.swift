//: Playground - noun: a place where people can play

import UIKit
import Endgame

extension UIStoryboard {
    func instantiate<A: UIViewController>(with type: A.Type) -> A {
        guard let vc = self.instantiateViewController(withIdentifier: String(describing: type.self)) as? A else {
            fatalError("Could not instantiate view controller \(A.self)") }
        return vc
    }
}

func indexPath(for itemIndex: Int?) -> IndexPath {
    guard let itemIndex = itemIndex else { return IndexPath(row: 0, section: 0) }
    let row = ((itemIndex % 2 == 0 ? 2 : 0) + (6 * (itemIndex + 1))) / 4
    return IndexPath(row: row, section: 0)
}

indexPath(for: nil)
indexPath(for: 0)
indexPath(for: 1)
indexPath(for: 2)
