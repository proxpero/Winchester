//
//  HistoryItem.swift
//  Endgame
//
//  Created by Todd Olsen on 9/20/16.
//
//

/// The type of the element stored in a `game`'s `history` property.
public struct HistoryItem {

    // MARK: Stored Properties

    public let position: Position
    public let move: Move?
    public let piece: Piece?
    public let capture: Capture?
    public let promotion: Piece?
    public let sanMove: String?

}

extension HistoryItem: Equatable {
    /// Returns `true` iff the two `HistoryItem` instances are the same.
    public static func == (lhs: HistoryItem, rhs: HistoryItem) -> Bool {
        return
            lhs.position == rhs.position &&
                lhs.move == rhs.move &&
                lhs.piece == rhs.piece &&
                lhs.capture?.piece == rhs.capture?.piece &&
                lhs.capture?.square == rhs.capture?.square &&
                lhs.promotion == rhs.promotion &&
                lhs.sanMove == rhs.sanMove
    }

}
