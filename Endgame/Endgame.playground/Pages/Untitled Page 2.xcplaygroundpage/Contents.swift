//: [Previous](@previous)

import UIKit

protocol Reusable {
    static var reuseIdentifier: String { get }
}

extension Reusable {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

public final class HeaderCell: UICollectionReusableView, Reusable {

}

public final class ShowGameCell: UICollectionViewCell, Reusable {

}

public final class ShowPuzzleCell: UICollectionViewCell, Reusable {
    
}

func cellClass() -> Reusable.Type {
    return HeaderCell.self
}

var str = cellClass().reuseIdentifier

//: [Next](@next)
