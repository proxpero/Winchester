//
//  Bitboard+Attacks.swift
//  Endgame
//
//  Created by Todd Olsen on 3/15/17.
//
//

extension Bitboard {

    /// Returns the pawn pushes available for `color` in `self`.
    func pawnPushes(for color: Color, empty: Bitboard) -> Bitboard {
        return (color.isWhite ? shifted(toward: .north) : shifted(toward: .south)) & empty
    }

    /// Returns the attacks available to `piece` in `self`.
    public func attacks(for piece: Piece, obstacles: Bitboard = 0) -> Bitboard {

        let diagonalSquares: Bitboard = {
            let ne = self
                .filled(toward: .northeast, until: obstacles)
                .shifted(toward: .northeast)
            let nw = self
                .filled(toward: .northwest, until: obstacles)
                .shifted(toward: .northwest)
            let se = self
                .filled(toward: .southeast, until: obstacles)
                .shifted(toward: .southeast)
            let sw = self
                .filled(toward: .southwest, until: obstacles)
                .shifted(toward: .southwest)
            return ne | nw | se | sw
        }()

        let orthogonalSquares: Bitboard = {
            let n = self
                .filled(toward: .north, until: obstacles)
                .shifted(toward: .north)
            let s = self
                .filled(toward: .south, until: obstacles)
                .shifted(toward: .south)
            let e = self
                .filled(toward: .east,  until: obstacles)
                .shifted(toward: .east)
            let w = self
                .filled(toward: .west,  until: obstacles)
                .shifted(toward: .west)
            return n | s | e | w
        }()

        switch piece.kind {

        case .pawn:
            switch piece.color {
            case .white:
                return shifted(toward: .northeast) | shifted(toward: .northwest)
            case .black:
                return shifted(toward: .southeast) | shifted(toward: .southwest)
            }

        case .knight:
            return
                (((self << 17) | (self >> 15)) & ~File.a) |
                (((self << 10) | (self >> 06)) & ~(File.a | File.b)) |
                (((self << 15) | (self >> 17)) & ~File.h) |
                (((self << 06) | (self >> 10)) & ~(File.g | File.h))

        case .bishop:
            return diagonalSquares

        case .rook:
            return orthogonalSquares

        case .queen:
            return diagonalSquares | orthogonalSquares

        case .king:
            let row = shifted(toward: .east) | shifted(toward: .west)
            let bitboard = self | row
            return row
                | bitboard.shifted(toward: .north)
                | bitboard.shifted(toward: .south)

        }
    }

}