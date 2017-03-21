//
//  Position+MoveValidation.swift
//  Endgame
//
//  Created by Todd Olsen on 3/20/17.
//
//

extension Position {

    /// Returns `true` if the move is legal.
    func canExecute(move: Move) -> Bool {
        return move.target.bitboard.intersects(_legalTargetSquares(from: move.origin, considerHalfmoves: true).bitboard)
    }

    func _legalTargetSquares(considerHalfmoves: Bool) -> [Square] {
        return _legalTargetSquares(for: playerTurn, considerHalfmoves: considerHalfmoves)
    }

    func _legalTargetsBitboard(for color: Color, considerHalfmoves: Bool) -> Bitboard {
        return board.bitboard(for: color).reduce(0) { $0 | _legalTargetSquares(from: $1, considerHalfmoves: considerHalfmoves).bitboard }
    }

    func _legalTargetSquares(for color: Color, considerHalfmoves: Bool = false) -> [Square] {
        return _legalTargetsBitboard(for: color, considerHalfmoves: considerHalfmoves).map { $0 }
    }

    func _attackedOccupations(for color: Color) -> [Square] {
        return board.attackedOccupations(for: color).map { $0 }
    }

    func pieceDefenses() -> [Color: [Square: Bitboard]] {
        /// TODO
        return [:]
        //        return board._pieceDefenses()
    }

    func _defendedOccupations(for color: Color) -> [Square] {
        return []
        //        return _pieceDefenses[color]!.filter { !$0.value.isEmpty }.map { $0.key }
    }

    func _undefendedOccupations(for color: Color) -> [Square] {
        return []
        //        return _pieceDefenses[color]!.filter { $0.value.isEmpty }.map { $0.key }
    }

    func _threatenedEnemies(for color: Color) -> [Square] {
        return board.threatenedEnemies(for: color).map { $0 }
    }

    func _attackers(targeting square: Square, for color: Color) -> [Square] {
        return board.attackers(targeting: square, color: color).map { $0 }
    }

    func _legalCaptures(for color: Color) -> [Square] {
        let moves = board.bitboard(for: color)
            .reduce(0) { $0 | _legalTargetSquares(from: $1).bitboard }
        let opponents = board.bitboard(for: color.inverse())
        return (moves & opponents).map { $0 }
    }

    func _legalCaptures(forPieceAt origin: Square) -> [Square] {
        let targets = _legalTargetSquares(from: origin).bitboard
        let opponents = board.bitboard(for: playerTurn.inverse())
        return (targets & opponents).map { $0 }
    }

    func legalTargets(from origin: Square, considerHalfmoves: Bool = false) -> [Square] {
        return []
    }

    /// Returns the moves bitboard currently available for the piece at `square`, if any.
    func _legalTargetSquares(from origin: Square, considerHalfmoves: Bool = false) -> [Square] {

        if considerHalfmoves && halfmoves >= 100 {
            return []
        }

        // No piece => no bitboard.
        guard
            let piece = board[origin],
            piece.color == playerTurn
            else { return [] }

        // Only the king can move if he is double checked.
        if isKingInMultipleCheck {
            guard piece.kind.isKing else {
                return []
            }
        }

        let playerBits = board.bitboard(for: playerTurn)
        let enemyBits = board.bitboard(for: playerTurn.inverse())
        let occupiedBits = playerBits | enemyBits
        let emptyBits = ~occupiedBits
        let squareBit = origin.bitboard

        var movesBitboard: Bitboard = 0

        let attacks = squareBit.attacks(for: piece, obstacles: occupiedBits)

        if piece.kind.isPawn {
            let enPassant = enPassantTarget.map { $0.bitboard } ?? 0
            let pushes = squareBit._pawnPushes(for: playerTurn, empty: emptyBits)
            let doublePushes = (squareBit & piece.startingPositions)
                ._pawnPushes(for: playerTurn, empty: emptyBits)
                ._pawnPushes(for: playerTurn, empty: emptyBits)
            movesBitboard |= pushes | doublePushes | (attacks & enemyBits) | (attacks & enPassant)
        } else {
            movesBitboard |= attacks & ~playerBits
        }

        if piece.kind.isKing && squareBit == piece.startingPositions && !isKingInCheck {
            for right in castlingRights {
                if right.color == playerTurn
                    && occupiedBits & right.emptySquares == 0
                    && (board.attacks(for: playerTurn.inverse()) & right.emptySquares) == 0
                {
                    movesBitboard |= right.castleSquare.bitboard
                }
            }
        }

        func isLegal(target: Square) -> Bool {
            let move = Move(origin: origin, target: target)
            let isEnPassant = (enPassantTarget != nil) && (enPassantTarget! == target)
            guard let (newBoard, _) = board.execute(uncheckedMove: move, for: playerTurn, isEnPassant: isEnPassant, promotion: Piece(queen: playerTurn)) else { return false }
            return newBoard.attackersToKing(for: playerTurn).count == 0
        }
        
        return movesBitboard.filter(isLegal)
    }

}
