//
//  Color.swift
//  Engine
//
//  Created by Todd Olsen on 8/4/16.
//
//

/// A color for one player or the other.
///
/// A `Color` can be one of two colors: black or white.
public enum Color: String, CustomStringConvertible {

    // MARK: Cases

    /// The color of the pieces that occupy the first two ranks
    /// of a standard chess game opening.
    case white

    /// The color of the pieces that occupy the last two ranks
    /// of a standard chess game opening.
    case black

    // MARK: - Initializers

    /// Craetes a color from a character (case insensitive).
    public init?(character: Character) {
        switch character {
        case "W", "w": self = .white
        case "B", "b": self = .black
        default: return nil
        }
    }

    // MARK: - Computed Properties

    /// Is `self` white of not.
    public var isWhite: Bool {
        return self == .white
    }

    /// Is `self` black or not.
    public var isBlack: Bool {
        return self == .black
    }

    /// The character representation of `self`. `.white` is "w", `.black` is "b".
    public var character: Character {
        return self.isWhite ? "w" : "b"
    }

    /// Returns the inverse of `self`.
    public func inverse() -> Color {
        return self.isWhite ? .black : .white
    }

    // MARK: - Mutating Functions

    /// Inverts the color of `self`.
    public mutating func invert() {
        self = inverse()
    }

    // MARK: - CustomStringConvertible Protocol Conformance

    /// A textual representation of `self`.
    public var description: String {
        return rawValue
    }

}
