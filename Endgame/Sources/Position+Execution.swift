//
//  Position+Execution.swift
//  Endgame
//
//  Created by Todd Olsen on 3/25/17.
//
//

extension Position {

    /// Hello 
    func execute(uncheckedMove move: Move, promotion: Piece? = nil) -> Game.Event? {

        // If there is no piece at the move's origin, there cannot be an event.
        guard let piece = board[move.origin] else {
            return nil
        }

        // Calculate the castling rights for the new position.
        let rights: Castle = {

            var result = castlingRights

            if piece.kind.isRook {
                switch move.origin {
                case .a1: result.remove(.whiteQueenside)
                case .h1: result.remove(.whiteKingside)
                case .a8: result.remove(.blackQueenside)
                case .h8: result.remove(.blackKingside)
                default:
                    break
                }
            } else if piece.kind.isKing {
                for option in castlingRights where option.color == playerTurn {
                    result.remove(option)
                }
            }
            return result

        }()

        // Calculate the new board and possible `capture` object for the move.
        guard let (newBoard, capture) = board.execute(uncheckedMove: move, for: playerTurn, isEnPassant: move.target == enPassantTarget, promotion: promotion) else { return nil }

        // Calculate the en passant square, if any.
        let enPassant: Square? = {
            guard
                let piece = board[move.origin],
                piece.kind.isPawn,
                abs(move.rankChange) == 2
                else { return nil }
            return Square(file: move.origin.file, rank: move.isUpward ? 3 : 6)
        }()

        // Returns the Standard Algebraic Notation string representation of the
        // move executed to create the new position.
        func sanMove(with newPosition: Position) -> String {

            if move.isCastle(for: playerTurn) {
                return move.isRightward ? "O-O" : "O-O-O"
            }

            var result = ""

            func disambiguation() -> String? {
                let attacks = board.attacks(by: piece, to: move.target)
                if piece.kind != .pawn && piece.kind != .king && attacks.count > 1 {
                    let sameFile = File.all
                        .map { $0.bitboard }
                        .reduce(false) { $0 || ($1 | attacks) == $1 }
                    let sameRank = Rank.all
                        .map { $0.bitboard }
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

            if isCapture {
                result.append("x")
            }

            result += move.target.description
            result += newPosition.kingStatus.san

            if let promotion = promotion, let char = promotion.kind.character {
                result += "=\(char)"
            }

            return result
        }

        // Calcualte the value of the halfmove clock.
        let newHalfmoves: UInt = {
            if capture == nil && !piece.kind.isPawn {
                return halfmoves + 1
            } else {
                return 0
            }
        }()

        // Create the new position.
        let newPosition = Position(
            board: newBoard,
            playerTurn: playerTurn.inverse(),
            castlingRights: rights,
            enPassantTarget: enPassant,
            halfmoves: newHalfmoves,
            fullmoves: playerTurn.isBlack ? fullmoves + 1 : fullmoves
        )

        return Game.Event(
            position: newPosition,
            history: Game.Event.History(
                move: move,
                piece: piece,
                capture: capture,
                promotion: promotion,
                sanMove: sanMove(with: newPosition)
            )
        )

    }

    func execute(sanMove: String) throws -> Game.Event? {
        let (move, promotion) = try self.move(for: sanMove)
        return execute(uncheckedMove: move, promotion: promotion)
    }

}
