//
//  Board+Execution.swift
//  Endgame
//
//  Created by Todd Olsen on 3/30/17.
//
//

extension Board {

    /// Performs a move on the board `self` and returns a new board and an optional
    /// `capture` if the move can be performed, otherwise returns nil.
    func execute(uncheckedMove move: Move, for color: PlayerTurn, isEnPassant: Bool, promotion: Piece?) -> (Board, Capture?)? {

        guard let piece = self[move.origin] else { return nil }

        var newBoard = self
        var endPiece = piece
        var captureSquare = move.target
        var capturePiece = self[captureSquare]

        if piece.kind.isPawn {
            if move.target.rank == Rank.ending(for: color)  {
                guard
                    let promo = promotion,
                    promo.kind.isPromotionType else {
                        fatalError("Unexpected Promotion: \(move)")
                }
                endPiece = Piece(kind: promo.kind, color: color)
            } else if isEnPassant {
                capturePiece = Piece(pawn: color.inverse())
                captureSquare = Square(file: move.target.file, rank: move.origin.rank)
            }
        } else if piece.kind.isKing {
            if move.isCastle() {
                let (old, new) = move.castleSquares()
                let rook = Piece(rook: color)
                newBoard[rook][old] = false
                newBoard[rook][new] = true
            }
        }

        var capture: Capture?

        newBoard[piece][move.origin] = false
        newBoard[endPiece][move.target] = true
        if let capturePiece = capturePiece {
            newBoard[capturePiece][captureSquare] = false
            capture = Capture(piece: capturePiece, square: captureSquare)
        }

        return (newBoard, capture)
    }


//    func execute(transaction: Transaction) -> Board {
//
//        var result = self
//
//        if let p = transaction.origin.piece {
//            result[p][transaction.origin.square] = false
//        }
//
//        if let p = transaction.target.piece {
//            result[p][transaction.target.square] = true
//        }
//
//        return result
//    }

    func execute(transactions: Set<Transaction>) -> Board {

        var result = self

        transactions.forEach { result.removePiece(at: $0.origin.square) }

        for target in transactions.map( { $0.target }) {
            if let p = target.piece {
                result[p][target.square] = true
            }
        }

        return result
    }
    
}
