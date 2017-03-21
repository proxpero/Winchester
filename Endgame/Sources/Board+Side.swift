//
//  Board+Side.swift
//  Endgame
//
//  Created by Todd Olsen on 3/15/17.
//
//

extension Board {
    /// A board side.
    public enum Side {

        /// The side comprising the four files on the king's of the board.
        case kingside

        /// The side comprising the four files on the queen's of the board.
        case queenside

        // MARK: Public Computed Properties.

        /// `self` is kingside.
        public var isKingside: Bool {
            return self == .kingside
        }

        /// `self` is queenside.
        public var isQueenside: Bool {
            return self == .queenside
        }
        
    }

}
