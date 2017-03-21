//
//  Board+Sequence.swift
//  Endgame
//
//  Created by Todd Olsen on 3/15/17.
//
//

extension Board: Sequence {

    /// Returns an iterator over the spaces of the board.
    public func makeIterator() -> Iterator {
        return Iterator(self)
    }

    /// An iterator for `Board`.
    public struct Iterator: IteratorProtocol {

        private let _board: Board
        private var _index: Int

        init(_ board: Board) {
            self._board = board
            self._index = 0
        }

        public mutating func next() -> Board.Space? {
            guard let square = Square(rawValue: _index) else {
                return nil
            }
            defer { _index += 1 }
            return _board.space(at: square)
        }
    }

}
