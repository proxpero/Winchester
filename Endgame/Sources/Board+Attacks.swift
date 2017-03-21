//
//  Board+Attacks.swift
//  Endgame
//
//  Created by Todd Olsen on 3/15/17.
//
//

extension Board {

    public func available(from square: Square) -> Bitboard {
        let space = self.space(at: square)
        guard let piece = space.piece else { return 0 }
        let all = square.bitboard.attacks(for: piece, obstacles: occupiedSpaces) & ~bitboard(for: piece.color)
        return all
    }

    public func legalTargets(from square: Square) -> (vacant: Bitboard, attacked: Bitboard) {

        let space = self.space(at: square)
        guard let piece = space.piece else { return (0,0) }

        let all = available(from: square)
        let opponent = bitboard(for: piece.color.inverse())
        return (all & ~opponent, all & opponent)
    }

    /// Return the attacks that can be made by `piece`
    public func attacks(for piece: Piece, obstacles: Bitboard) -> Bitboard {
        return self[piece].attacks(for: piece, obstacles: obstacles)
    }

    /// Returns the attacks that can be made by `color`
    public func attacks(for color: Color) -> Bitboard {
        return Piece.pieces(for: color).reduce(0) { $0 | attacks(for: $1, obstacles: occupiedSpaces) }
    }

    /// Returns the attackers to `square` corresponding to `color`.
    ///
    /// - parameter square: The `Square` being attacked.
    /// - parameter color: The `Color` of the attackers.
    public func attackers(targeting square: Square, color: Color) -> Bitboard {
        let all = occupiedSpaces
        let attackingPieces = Piece.pieces(for: color)
        let defendingPieces = Piece.pieces(for: color.inverse())
        let attacks = defendingPieces.map({ piece in
            square.bitboard.attacks(for: piece, obstacles: all)
        })
        let queens = (attacks[2] | attacks[3]) & self[Piece(queen: color)]
        return zip(attackingPieces, attacks)
            .map({ self[$0] & $1 })
            .reduce(queens, |)
    }

    /**
     Returns a bitboard of pieces of the same kind and color that are
     attacking the same square, useful for discovering ambiguities.
     */
    public func attacks(by piece: Piece, to square: Square) -> Bitboard {
        return square.bitboard.attacks(for: piece, obstacles: occupiedSpaces) & bitboard(for: piece)
    }

    /// Returns the attackers to the king for `color`.
    ///
    /// - parameter color: The `Color` of the potentially attacked king.
    ///
    /// - returns: A bitboard of all attackers, or 0 if the king does not exist
    ///   or if there are no pieces attacking the king.
    public func attackersToKing(for color: Color) -> Bitboard {
        guard let square = squareForKing(for: color) else {
            return 0
        }
        return attackers(targeting: square, color: color.inverse())
    }

    /// Returns `true` if the king for `color` is in check.
    public func isKingInCheck(for color: Color) -> Bool {
        return attackersToKing(for: color) != 0
    }

    public func isKingInMultipleCheck(for color: Color) -> Bool {
        return attackersToKing(for: color).count > 1
    }

    public func defendedOccupations(for color: Color) -> [Space: Bitboard] {
        var result: [Space: Bitboard] = [:]
        for space in spaces(for: color) {
            result[space] = attackers(targeting: space.square, color: color)
        }
        return result
    }

//    internal func _pieceDefenses() -> [Color: [Square: Bitboard]] {
//        var result: [Color: [Square: Bitboard]] = [:]
//        for color in [Color.white, Color.black] {
//            var side: Dictionary<Square, Bitboard> = [:]
//            for square in squares(for: color) {
//                var board = self
//                board.removePiece(at: square)
//                let defenders = board.attackers(targeting: square, color: color)
//                side[square] = defenders
//            }
//            result[color] = side
//        }
//        return result
//    }

    internal func attackedOccupations(for color: Color) -> Bitboard {
        let mine = pieces(for: color).reduce(0) { $0 | self[$1] }
        return attacks(for: color.inverse()) & mine
    }

    internal func threatenedEnemies(for color: Color) -> Bitboard {
        let enemies = pieces(for: color.inverse()).reduce(0) { $0 | self[$1] }
        return attacks(for: color) & enemies
    }

}
