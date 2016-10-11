
import CoreGraphics
import SpriteKit
import Engine

extension Int {

    var isEven: Bool {
        return self % 2 == 0
    }

    /// Returns whether `self` as an row index in the collection view is a `number` cell.
    var isNumberRow: Bool {
        return (self-1)%3 == 0
    }

    /// Converts the index from a game's history array to its corresponding row index in the collection view.
    var asRowIndex: Int {
        return ((self.isEven ? 2 : 0) + (6 * (self + 1))) / 4
    }

    /// Converts a collection view cell index to a natural number index.
    var asNumberIndex: Int {
        return (self-1)/3 + 1
    }

    /// Converts a collection view cell index to its index in a `game`'s `moveHistory`.
    func moveIndex() -> Int {
        return 2*self/3 // - 1
    }

    /// Returns the next index after `self` of a move in a history collection view.
    func nextMoveIndex() -> Int {
        let next = self + 1
        return next + (next.isNumberRow ? 1 : 0)
    }

    /// Returns the previous index before `self` of a move in a history collection view.
    func previousMoveIndex() -> Int {
        let prev = self - 1
        return prev - (prev.isNumberRow ? 1 : 0)
    }
    
}


for i in [2, 3, 5, 6, 8, 9, 11, 12] {
    print(i.asNumberIndex)
}

