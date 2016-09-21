//
//  Position+LegalMoves.swift
//  Engine
//
//  Created by Todd Olsen on 9/20/16.
//
//

extension Position {

    /// Returns `true` if the move is legal.
    internal func _canExecute(move: Move) -> Bool {
        return move.target.bitmask.intersects(_legalTargets(from: move.origin, considerHalfmoves: true).bitmask)
    }

    internal func _legalTargets(considerHalfmoves: Bool) -> [Square] {
        return board.bitboard(for: playerTurn)
            .reduce(0) { $0 | _legalTargets(from: $1, considerHalfmoves: considerHalfmoves).bitmask }
            .map { $0 }
    }

    /// Returns the moves bitboard currently available for the piece at `square`, if any.
    internal func _legalTargets(from origin: Square, considerHalfmoves: Bool) -> [Square] {

        if considerHalfmoves && halfmoves >= 100 {
            return []
        }

        // No piece -> no bitboard.
        guard let piece = board[origin], piece.color == playerTurn else {
            return []
        }

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
        let squareBit = origin.bitmask

        var movesBitboard: Bitboard = 0
        let attacks = origin.attacks(for: piece, obstacles: occupiedBits)

        if piece.kind.isPawn {
            let enPassant = enPassantTarget.map { $0.bitmask } ?? 0
            let pushes = squareBit._pawnPushes(for: playerTurn, empty: emptyBits)
            let doublePushes = (squareBit & piece.startingPositions)
                ._pawnPushes(for: playerTurn, empty: emptyBits)
                ._pawnPushes(for: playerTurn, empty: emptyBits)
            movesBitboard |= pushes | doublePushes
                | (attacks & enemyBits)
                | (attacks & enPassant)
        } else {
            movesBitboard |= attacks & ~playerBits
        }

        if piece.kind.isKing && squareBit == piece.startingPositions {
            for right in castlingRights {
                // FIXME: Also take care that empty spaces are not attacked.
                if right.color == playerTurn && occupiedBits & right.emptySquares == 0 {
                    movesBitboard |= right.castleSquare.bitmask
                }
            }
        }

        func isLegal(target: Square) -> Bool {
            return _canExecute(move: Move(origin: origin, target: target))
        }

        return movesBitboard.filter(isLegal)
    }

    internal func _execute(uncheckedMove move: Move, promotion: Piece? = nil) -> HistoryItem? {

        guard let piece = board[move.origin] else {
            return nil
        }

        var newBoard = board
        var endPiece = piece
        var captureSquare = move.target
        var capture = board[captureSquare]
        var rights = castlingRights

        if piece.kind.isPawn {
            if move.target.rank == Rank(endFor: playerTurn) {
                guard
                    let promo = promotion,
                    promo.kind.isPromotionType() else {
                    fatalError("Unexpected Promotion: \(promotion)")
                }
                endPiece = Piece(kind: promo.kind, color: playerTurn)
            } else if move.target == enPassantTarget {
                capture = Piece(pawn: playerTurn.inverse())
                captureSquare = Square(file: move.target.file, rank: move.origin.rank)
            }
        } else if piece.kind.isRook {
            switch move.origin {
            case .a1: rights.remove(.whiteQueenside)
            case .h1: rights.remove(.whiteKingside)
            case .a8: rights.remove(.blackQueenside)
            case .h8: rights.remove(.blackKingside)
            default:
                break
            }
        } else if piece.kind.isKing {
            for option in castlingRights where option.color == playerTurn {
                rights.remove(option)
            }
            if move.isCastle(for: playerTurn) {
                let (old, new) = move._castleSquares()
                let rook = Piece(rook: playerTurn)
                newBoard[rook][old] = false
                newBoard[rook][new] = true
            }
        }

        newBoard[piece][move.origin] = false
        newBoard[endPiece][move.target] = true
        if let capture = capture {
            newBoard[capture][captureSquare] = false
        }

        let enPassant: Square? = {
            guard
                let piece = board[move.target],
                piece.kind.isPawn,
                abs(move.rankChange) == 2
                else { return nil }
            return Square(file: move.origin.file, rank: move.isUpward ? 3 : 6)
        }()

        /// Returns the Standard Algebraic Notation string representation of the
        /// move executed to create the new position.
        func sanMove(with newPosition: Position) -> String {

            if move.isCastle(for: playerTurn) {
                return move.isRightward ? "O-O" : "O-O-O"
            }

            var result = ""

            func disambiguation() -> String? {
                let attacks = board.attacks(by: piece, to: move.target)
                if piece.kind != .pawn && piece.kind != .king && attacks.count > 1 {
                    let sameFile = File.all
                        .map { $0.bitmask }
                        .reduce(false) { $0 || ($1 | attacks) == $1 }
                    let sameRank = Rank.all
                        .map { $0.bitmask }
                        .reduce(false) { $0 || ($1 | attacks) == $1 }
                    switch (sameFile, sameRank) {
                    case (true, false): return move.origin.rank.description
                    case (false, _): return String(move.origin.file.character)
                    default: return String(move.origin.file.character) + move.origin.rank.description
                    }
                }
                return nil
            }

            let isCapture = capture != nil

            if let c = piece.kind.character {
                result.append(c)
                if let disambiguation = disambiguation() {
                    result += disambiguation
                }
            } else if isCapture {
                result.append(move.origin.file.character)
            }

            if isCapture{
                result.append("x")
            }

            result += move.target.description
            result += newPosition._kingStatus.algebraicAnnotation
            return result
        }

        let newHalfmoves: UInt = {
            if capture == nil && !piece.kind.isPawn {
                return halfmoves + 1
            } else {
                return 0
            }
        }()

        let newPosition = Position(
            board: newBoard,
            playerTurn: playerTurn.inverse(),
            castlingRights: rights,
            enPassantTarget: enPassant,
            halfmoves: newHalfmoves,
            fullmoves: playerTurn.isBlack ? fullmoves + 1 : fullmoves
        )

        return HistoryItem(
            position: newPosition,
            move: move,
            piece: piece,
            capture: capture,
            sanMove: sanMove(with: newPosition)
        )
    }

}
