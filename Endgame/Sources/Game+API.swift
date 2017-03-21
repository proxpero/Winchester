//
//  Game+API.swift
//  Endgame
//
//  Created by Todd Olsen on 3/21/17.
//
//

extension Game {

    // MARK: - Public API

    /// Returns the color of the player whose turn it is.
    public var playerTurn: Color {
        return currentPosition.playerTurn
    }

    /// The game's outcome.
    public var outcome: Outcome? {
        return currentPosition.outcome
    }

    public subscript(color: Color) -> Player {
        get {
            return color.isWhite ? whitePlayer : blackPlayer
        }
        set {
            switch color {
            case .white: whitePlayer = newValue
            case .black: blackPlayer = newValue
            }
        }
    }

    public var currentIndex: Int? {
        return _currentIndex
    }

    /// Returns the last move of the position.
    public var latestMove: Move? {
        guard let current = _currentIndex else {
            return nil
        }
        return _items[current].move
    }

    public var lastSanMove: String? {
        guard let current = _currentIndex else {
            return nil
        }
        return _items[current].sanMove
    }

    /// Returns whether `move` is a promotion.
    public func isPromotion(for move: Move) -> Bool {
        return currentPosition.board[move.target]?.kind == .pawn && move.reachesEndRank(for: playerTurn)
    }

    /// Returns the squares a side could potentially occupy.
    ///
    /// - parameter color: The player on whose behalf the computation is made.
    ///
    /// - returns: An array of `Square`s.
    public func availableTargets(for color: Color) -> [Square] {
        return currentPosition._legalTargetSquares(for: color)
    }

    public func availableCaptures(for color: Color) -> [Square] {
        return currentPosition._legalCaptures(for: color)
    }

    public func availableTargets(forPieceAt square: Square) -> [Square] {
        return currentPosition._legalTargetSquares(from: square)
    }

    public func availableCaptures(forPieceAt square: Square) -> [Square] {
        return currentPosition._legalCaptures(forPieceAt: square)
    }

    public var squaresAttackingKing: [Square] {
        return currentPosition.attackersToKing.map { $0 }
    }

    public func movesAttackingKing() -> [Move] {
        guard let kingSquare = currentPosition.board.squareForKing(for: currentPosition.playerTurn) else { return [] }
        return currentPosition.attackersToKing.map { Move(origin: $0, target: kingSquare) }
    }

    public func attackedOccupations(for color: Color) -> [Square] {
        return currentPosition._attackedOccupations(for: color)
    }

    public func defendedOccupations(for color: Color) -> [Square] {
        return currentPosition._defendedOccupations(for: color)
    }

    public func undefendedOccupations(for color: Color) -> [Square] {
        return currentPosition._undefendedOccupations(for: color)
    }

    public func threatenedEnemies(for color: Color) -> [Square] {
        return currentPosition._threatenedEnemies(for: color)
    }

    public func attackers(targeting square: Square, for color: Color) -> ([Square]) {
        return currentPosition._attackers(targeting: square, for: color)
    }

    public func execute(sanMoves: String) throws {
        for sanMove in sanMoves.components(separatedBy: " ") {
            let (move, promotion) = try currentPosition.move(for: sanMove)
            try execute(move: move, promotion: promotion)
        }
    }

    /// Execute `move`.
    public func execute(move: Move, promotion: Piece? = nil) throws {

        // execute move
        guard let newHistoryItem = currentPosition.execute(uncheckedMove: move, promotion: promotion) else {
            fatalError("Could not execute move: \(move.description)")
        }

        // Remove "undone moves" from the items array.
        if let current = _currentIndex, current + 1 < endIndex {
            _items.removeSubrange((current + 1)..<_items.endIndex)
        }
        _items.append(newHistoryItem)
        _currentIndex = _items.endIndex - 1
        delegate?.game(self, didAppend: newHistoryItem, at: _currentIndex)

        let key = self.flatMap { $0.sanMove }.joined(separator: " ")
        if let e = ECO.codes[key] {
            print(e.name)
        }

        delegate?.game(self, didExecute: move, with: newHistoryItem.capture, with: promotion)

        if let outcome = currentPosition.outcome {
            delegate?.game(self, didEndWith: outcome)
        }

    }

    // MARK: - Public Computed Properties

    public var currentPosition: Position {
        guard let current = _currentIndex else {
            return _startingPosition
        }
        return _items[current].position
    }

    // MARK: - Move Undo/Redo: Public Functions

    /// Sets the game's currentIndex to the starting position.
    @discardableResult
    public func undoAll() -> ArraySlice<HistoryItem> {
        guard let count = _currentIndex else { return [] }
        return undo(count: count + 1)
    }

    /// Sets the game's currentIndex to the ending position.
    ///
    /// - returns: A corresponding slice of `items`.
    @discardableResult
    public func redoAll() -> ArraySlice<HistoryItem> {
        return redo(count: _items.count)
    }

    /// Decrements `currentIndex` and returns the undone history items in the
    /// order in which they must be executed in order to recreate the redone state.
    ///
    /// - parameter count: The number of moves to undo. Default is 1.
    ///
    /// - returns: An optional array of history items.
    @discardableResult
    public func undo(count: Int = 1) -> ArraySlice<HistoryItem> {
        guard let current = _currentIndex else {
            return ArraySlice<HistoryItem>()
            //            fatalError("Cannot undo the initial position")
        }
        let newIndex: Int?
        let range: Range<Int>

        if count == 0 {
            return []
        } else if count == current + 1 {
            newIndex = nil
            range = startIndex ..< current+1
        } else {
            newIndex = current - count
            range = (newIndex!+1)..<(current+1)
        }

        _currentIndex = newIndex
        return _items[range]
    }

    /// Increments the currentIndex and returns the redone history items in the order
    /// in which they must executed in order to recreate the undone state.
    ///
    /// - parameter count: The number of moves to redo. Default is 1.
    ///
    /// - returns: An optional array of history items.
    @discardableResult
    public func redo(count: Int = 1) -> ArraySlice<HistoryItem> {

        if count == 0 {
            return []
        }

        let newIndex: Int
        let range: Range<Int>

        if let current = _currentIndex {
            newIndex = current + count
            range = (current+1) ..< (newIndex+1)
        } else {
            newIndex = count - 1
            range = _items.startIndex ..< count
        }
        _currentIndex = newIndex
        if !_items.indices.contains(range.lowerBound) || !_items.indices.contains(range.upperBound-1) {
            return []
        }
        return _items[range]
    }

}
