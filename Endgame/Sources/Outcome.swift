//
//  Outcome.swift
//  Endgame
//
//  Created by Todd Olsen on 9/20/16.
//
//

/// A (logical) outcome of a chess game. This is the outcome
/// as determined by the rules of chess, not as determined,
/// for example, by a resignation, or other premature end
/// to the game.
public enum Outcome  {

    /// A victory for `Color`.
    case win(Color)

    /// A draw.
    case draw

    /// Creates an `Outcome` from a string representation. Trims whitespace.
    public init?(_ string: String?) {

        guard let input = string else { return nil }
        let stripped = input.characters
            .split(separator: " ")
            .map(String.init)
            .joined(separator: "")
        switch stripped {
        case Outcome.whiteWin: self = .win(.white)
        case Outcome.blackWin: self = .win(.black)
        case Outcome.drawnGame: self = .draw
        default:
            return nil
        }
    }

    static let whiteWin = "1-0"
    static let blackWin = "0-1"
    static let drawnGame = "1/2-1/2"
    static let indeterminantGame = "*"

}

extension Outcome {

    /// An array of all possible outcomes.
    static var all: [Outcome] {
        return [.win(.white), .win(.black), .draw]
    }

    /// The winning color of `self`, or `nil` if it is a draw.
    public var winner: Color? {
        guard case .win(let color) = self else { return nil }
        return color
    }

    /// Returns a `true` if `self` is a win?
    public var isWin: Bool {
        if case .win = self { return true } else { return false }
    }

    /// Returns `true` if `self` is a draw?
    public var isDraw: Bool {
        if case .draw = self { return true } else { return false }
    }

    private static let winValue = 1.0
    private static let lossValue = 0.0
    private static let drawValue = 0.5

    /// The point value for a player. The default values are: win: 1.0, loss: 0.0, draw: 0.5.
    public func value(for playerColor: Color) -> Double {
        return winner.map({ $0 == playerColor ? Outcome.winValue : Outcome.lossValue }) ?? Outcome.drawValue
    }

    /// A user facing text representation of `self`
    public var userDescription: String {
        switch self {
        case .win(let color):
            return color.isWhite ? "1﹘0" : "0﹘1"
        case .draw:
            return "½﹘½"
        }
    }

}

extension Outcome {

    /// The SAN representation of `self`
    var san: String {
        switch self {
        case .win(let color):
            switch color {
            case .white:
                return Outcome.whiteWin
            case .black:
                return Outcome.blackWin
            }
        case .draw:
            return Outcome.drawnGame
        }
    }

    /// The point value for `self`
    var value: Double {
        switch self {
        case .win:
            return 1.0
        case .draw:
            return 0.5
        }
    }

}

extension Outcome: CustomStringConvertible {

    /// A textual representation of `self`.
    public var description: String {
        switch self {
        case .win(let color):
            return color.isWhite ? Outcome.whiteWin : Outcome.blackWin
        case .draw:
            return Outcome.drawnGame
        }
    }

}

extension Outcome: Equatable {

    /// Returns `true` iff the two `Outcome` instances `lhs` and `rhs` are the 
    /// same.
    public static func == (lhs: Outcome, rhs: Outcome) -> Bool {
        return lhs.winner == rhs.winner
    }

}

extension Outcome: Hashable {

    /// The hash value of `self`.
    public var hashValue: Int {
        return winner?.hashValue ?? 2
    }

}

