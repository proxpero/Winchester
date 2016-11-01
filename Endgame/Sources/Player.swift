//
//  Player.swift
//  Endgame
//
//  Created by Todd Olsen on 8/4/16.
//
//

/// A chess game player.
public struct Player: Equatable, CustomStringConvertible {

    // MARK: Stored Properties

    public var kind: Kind
    public var name: String?
    public var elo: UInt?

    // MARK: Initializers

    /// Create an instance of `Player`
    ///
    /// - parameter name: The name of the Player, defaults to `nil`.
    /// - parameter kind: The kind of the Player, defaults to `.human`.
    /// - parameter elo:  An optional `Double` representation of the player's
    ///   elo, defaults to `nil`.
    public init(name: String? = nil, kind: Kind = .human, elo: UInt? = nil) {
        self.kind = kind
        self.name = name
        self.elo = elo
    }

    /// Create an instance of `Player`
    ///
    /// - parameter name: The name of the Player
    /// - parameter kind: A string representation of the kind of player, 
    ///   for example, "program"
    /// - parameter elo:  A string representation of the player's elo
    public init(name: String?, kind: String?, elo: String?) {
        let kind = Player.Kind(pgnPlayerTypeTag: kind)
        let num = (elo != nil) ? UInt(elo!) : nil
        self.init(name: name, kind: kind, elo: num)
    }

    // MARK: Computed Properties and Functions

    public var description: String {
        return "Player(kind: \(kind), name: \(name), elo: \(elo))"
    }

    // MARK: Equatable Conformance

    public static func == (lhs: Player, rhs: Player) -> Bool {
        return true
    }
}

// MARK: -
// MARK: Player.Kind

extension Player {

    /// A kind of player, whether `.human` or `.computer`.
    public enum Kind: String, CustomStringConvertible {

        // MARK: Cases

        /// A Human player.
        case human = "Human"

        /// A Computer player
        case computer = "Computer"

        // MARK: Public Computed Properties

        /// Returns `true` if `self` is a human player.
        public var isHuman: Bool {
            return self == .human
        }

        /// Returns `true` if `self` is a computer player.
        public var isComputer: Bool {
            return self == .computer
        }

        public var description: String {
            return rawValue
        }
    }
}

// MARK: -
// MARK: Player.Kind + PGN

extension Player.Kind {

    // MARK: Public Initializers

    /// Initialize an instance of `Player.Kind` from a pgn tag. Defaults to
    /// `.human`
    public init(pgnPlayerTypeTag: String? = nil) {
        if
            let tag = pgnPlayerTypeTag,
            tag.lowercased() == "program"
        {
            self = .computer
        }
        self = .human
    }
}
