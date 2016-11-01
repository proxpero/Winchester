//: Playground - noun: a place where people can play

import UIKit

extension UIStoryboard {
    func instantiate<A: UIViewController>(with type: A.Type) -> A {
        guard let vc = self.instantiateViewController(withIdentifier: String(describing: type.self)) as? A else {
            fatalError("Could not instantiate view controller \(A.self)") }
        return vc
    }
}
