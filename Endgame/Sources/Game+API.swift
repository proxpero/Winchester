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

//    public var currentIndex: Int? {
//        return _currentIndex
//    }

    public var currentEvent: Event {
        return self[moveIndex]
    }

    public var currentPosition: Position {
        return currentEvent.position
    }


    /// Returns the move that created the current position.
    public var latestMove: Move? {
        return currentEvent.history?.move
    }

    public var lastSanMove: String? {
        return currentEvent.history?.sanMove
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
        return currentPosition.legalTargetSquares(for: color)
    }

    public func availableCaptures(for color: Color) -> [Square] {
        return currentPosition.legalCaptures(for: color)
    }

    public func availableTargets(forPieceAt square: Square) -> [Square] {
        return currentPosition.legalTargetSquares(from: square)
    }

    public func availableCaptures(forPieceAt square: Square) -> [Square] {
        return currentPosition.legalCaptures(forPieceAt: square)
    }

    public var squaresAttackingKing: [Square] {
        return currentPosition.attackersToKing.map { $0 }
    }

    public func movesAttackingKing() -> [Move] {
        guard let kingSquare = currentPosition.board.squareForKing(for: currentPosition.playerTurn) else { return [] }
        return currentPosition.attackersToKing.map { Move(origin: $0, target: kingSquare) }
    }

    public func attackedOccupations(for color: Color) -> [Square] {
        return currentPosition.attackedOccupations(for: color)
    }

    public func defendedOccupations(for color: Color) -> [Square] {
        return currentPosition.defendedOccupations(for: color)
    }

    public func undefendedOccupations(for color: Color) -> [Square] {
        return currentPosition.undefendedOccupations(for: color)
    }

    public func threatenedEnemies(for color: Color) -> [Square] {
        return currentPosition.threatenedEnemies(for: color)
    }

    public func attackers(targeting square: Square, for color: Color) -> ([Square]) {
        return currentPosition.attackers(targeting: square, for: color)
    }

    public func execute(sanMoves: [String]) throws {
        for san in sanMoves {
            do {
                let (move, promotion) = try currentPosition.move(for: san)
                execute(move: move, promotion: promotion)
            } catch {
                throw ParseError.invalidMove(san)
            }
        }
    }

    public func execute(sanMoves: String) throws {
        try execute(sanMoves: sanMoves.components(separatedBy: " "))
    }

    /// Execute `move`.
    public func execute(move: Move, promotion: Piece? = nil) {
        guard let newEvent = currentPosition.execute(uncheckedMove: move, promotion: promotion) else {
            fatalError("Could not execute move: \(move.description)")
        }

        events.removeLast(events.endIndex - moveIndex - 1)
        events.append(newEvent)
        moveIndex = events.index(before: events.endIndex)

        delegate?.game(self, didExecute: move, with: newEvent.history?.capture, with: promotion)

        if let eco = eco {
            delegate?.game(self, didRecalculateECO: eco)
        }

        if let outcome = currentPosition.outcome {
            delegate?.game(self, didEndWith: outcome)
        }

    }

    // MARK: - Public Computed Properties

//    public var currentPosition: Position {
//        guard let current = _currentIndex else {
//            return _items[_items.startIndex].position
////            return _startingPosition
//        }
//        return _items[current].position
//    }

    // MARK: - Move Undo/Redo: Public Functions


}
