//
//  HistoryItem.swift
//  Engine
//
//  Created by Todd Olsen on 9/20/16.
//
//

// MARK: -

/// The type of the element stored in a `game`'s `history` property.
public struct HistoryItem: Equatable {

    // MARK: Stored Properties

    public let position: Position
    public let move: Move
    public let piece: Piece
    public let capture: Piece?
    public let sanMove: String

    // MARK: - Equatable Protocol Conformance

    /// Returns `true` iff the two `HistoryItem` instances are the same.
    public static func == (lhs: HistoryItem, rhs: HistoryItem) -> Bool {
        return
            lhs.position == rhs.position &&
            lhs.move == rhs.move &&
            lhs.piece == rhs.piece &&
            lhs.capture == rhs.capture &&
            lhs.sanMove == rhs.sanMove
    }

}

// MARK: -

/// The states a king could be in during a game.
public enum KingStatus {
    case safe
    case checked
    case checkmated

    var algebraicAnnotation: String {
        switch self {
        case .checkmated:
            return "#"
        case .checked: return "+"
        default:
            return ""
        }
    }
}
