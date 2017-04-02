//
//  Game+Event.swift
//  Endgame
//
//  Created by Todd Olsen on 3/26/17.
//
//

extension Game {

    public struct Event {

        /// A Type that encapsulates the state that led to the creation of an
        /// `Event`'s `position`.
        public struct History {

            /// The move that was executed on the previous position to produce this position.
            public let move: Move

            /// The piece that executed `move` to create the current position.
            public let piece: Piece

            /// The `Space` that was captured, if any, to produce this move.
            public let capture: Capture?

            /// The `Piece` that was chosen in the promotion of a pawn to produce this move.
            public let promotion: Piece?

            /// The `SAN` move representation of the move that produced this position.
            public let sanMove: String

        }

        /// The `Position` which this `Event` culminates in.
        public let position: Position

        /// The `history` instance which led to the event's position.
        public let history: History?

    }
}

extension Game.Event: Equatable {

    /// Equatable conformance
    public static func ==(lhs: Game.Event, rhs: Game.Event) -> Bool {
        return lhs.position == rhs.position && lhs.history == rhs.history
    }

}

extension Game.Event.History: Equatable {

    /// Equatable conformance.
    public static func ==(lhs: Game.Event.History, rhs: Game.Event.History) -> Bool {
        return lhs.move == rhs.move &&
            lhs.piece == rhs.piece &&
            lhs.sanMove == rhs.sanMove &&
            lhs.capture == rhs.capture &&
            lhs.promotion == rhs.promotion
    }
    
}

extension Game.Event {

    /// A direction for traversing the events of a game.
    public enum Direction {

        /// The direction moving toward the beginning of the game.
        case undo

        /// The direction moving toward the end of the game.
        case redo

        /// Returns `true` iff `self` is the `undo` direction.
        public var isUndo: Bool {
            switch self {
            case .undo:
                return true
            default:
                return false
            }
        }

        /// Returns `true` iff `self` is the `redo` direction.
        public var isRedo: Bool {
            switch self {
            case .redo:
                return true
            default:
                return false
            }
        }

        /// Create a `Direction` by  comparing two indices. If
        /// `currentIndex` is greater than `newIndex` then `self` is `undo`.
        /// Otherwise, `self` is `redo`.
        public init?(currentIndex: Int, newIndex: Int) {
            self = currentIndex > newIndex ? .undo : .redo
        }
    }
    
}
