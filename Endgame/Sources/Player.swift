//
//  Player.swift
//  Endgame
//
//  Created by Todd Olsen on 8/4/16.
//
//

/// A chess game player.
public struct Player {

    /// The `Kind` of `self`, whether `Human` or `Computer`
    public var kind: Kind

    /// The name of the player.
    public var name: String?

    /// The `ELO` value of the player.
    public var elo: UInt?

}

extension Player {

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

}

extension Player: CustomStringConvertible {

    /// The string representation of `self`
    public var description: String {
        return "Player(kind: \(kind), name: \(name), elo: \(elo))"
    }

}


extension Player: Equatable {

    /// Equatable protocol conformance
    public static func == (lhs: Player, rhs: Player) -> Bool {
        return true
    }

}


extension Player {

    /// A kind of player, whether `.human` or `.computer`.
    public enum Kind: String {

        /// A Human player.
        case human = "Human"

        /// A Computer player
        case computer = "Computer"

        /// Returns `true` if `self` is a human player.
        public var isHuman: Bool {
            return self == .human
        }

        /// Returns `true` if `self` is a computer player.
        public var isComputer: Bool {
            return self == .computer
        }

    }

}

extension Player.Kind {

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

extension Player.Kind: CustomStringConvertible {

    /// A string representation of `self`
    public var description: String {
        return rawValue
    }

}
