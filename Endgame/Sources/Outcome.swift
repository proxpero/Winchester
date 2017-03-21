//
//  Outcome.swift
//  Endgame
//
//  Created by Todd Olsen on 9/20/16.
//
//

/// An outcome of a chess game.
public enum Outcome: CustomStringConvertible, Hashable  {

    // MARK: Cases

    /// A victory for `Color`.
    case win(Color)

    /// A draw.
    case draw

    /// An indeterminant outcome.
//    case undetermined

    static var all: [Outcome] {
        return [.win(.white), .win(.black), .draw /*, .undetermined */]
    }

    // MARK: Initializers

    /// Creates an `Outcome` from a string representation. Trims whitespace.
    public init?(_ string: String?) {

        guard let input = string else { return nil }
        let stripped = input.characters.split(separator: " ").map(String.init).joined(separator: "")
        switch stripped {
        case Outcome.whiteWin: self = .win(.white)
        case Outcome.blackWin: self = .win(.black)
        case Outcome.drawnGame: self = .draw
//        case Outcome.indeterminantGame: self = .undetermined
        default:
            return nil
        }
    }

    // MARK: Computed Properties and Functions

    /// The `Color` of the winning player.
    public var winningColor: Color? {
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

//    public var isUndetermined: Bool {
//        if case .undetermined = self { return true } else { return false }
//    }

    /// The point value for a player. The default values are: win: 1.0, loss: 0.0, draw: 0.5.
    public func value(for playerColor: Color) -> Double {
        return winningColor.map({ $0 == playerColor ? Outcome.winValue : Outcome.lossValue }) ?? Outcome.drawValue
    }

    // MARK: Protocol conformance

    /// The hash value of `self`.
    public var hashValue: Int {
        return winningColor?.hashValue ?? 2
    }

    /// A textual representation of `self`.
    public var description: String {
        switch self {
        case .win(let color):
            return color.isWhite ? Outcome.whiteWin : Outcome.blackWin
        case .draw:
            return Outcome.drawnGame
//        case .undetermined:
//            return Outcome.indeterminantGame
        }
    }

    /// A user facing text representation of `self`
    public var userDescription: String {
        switch self {
        case .win(let color):
            return color.isWhite ? "1﹘0" : "0﹘1"
        case .draw:
            return "½﹘½"
//        case .undetermined:
//            return "❊"
        }
    }

    // MARK: Static Constants
    public static let whiteWin = "1-0"
    public static let blackWin = "0-1"
    public static let drawnGame = "1/2-1/2"
    public static let indeterminantGame = "*"
    public static let winValue = 1.0
    public static let lossValue = 0.0
    public static let drawValue = 0.5

    // MARK: Equatable Protocol Conformance

    /// Returns `true` iff the two outcomes are the same.
    public static func == (lhs: Outcome, rhs: Outcome) -> Bool {
        return lhs.winningColor == rhs.winningColor
    }

}
