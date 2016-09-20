//
//  File.swift
//  Engine
//
//  Created by Todd Olsen on 8/4/16.
//
//

/// A file (column) of the chess board.
///
/// A `File` can be one of eight possible values beginning with `A` on the left through `H` on the right.
public enum File: Int, BoardCoordinate, CustomStringConvertible, ExpressibleByExtendedGraphemeClusterLiteral {

    // MARK: -

    /// A direction in file.
    public enum Direction {

        // MARK: Cases

        /// Left direction.
        case left

        /// Right direction.
        case right

    }

    // MARK: - Cases

    /// File "A".
    case a = 1

    /// File "B".
    case b = 2

    /// File "C".
    case c = 3

    /// File "D".
    case d = 4

    /// File "E".
    case e = 5

    /// File "F".
    case f = 6

    /// File "G".
    case g = 7

    /// File "H".
    case h = 8

    // MARK: Initializers

    /// Create an instance from a character value (case insensitive).
    public init?(_ character: Character) {
        switch character {
        case "A", "a": self = .a
        case "B", "b": self = .b
        case "C", "c": self = .c
        case "D", "d": self = .d
        case "E", "e": self = .e
        case "F", "f": self = .f
        case "G", "g": self = .g
        case "H", "h": self = .h
        default: return nil
        }
    }

    /// Create a `File` from a zero-based column index.
    public init?(index: Int) {
        self.init(rawValue: index + 1)
    }

    /// Create an instance initialized to `value`.
    public init(unicodeScalarLiteral value: Character) {
        guard let file = File(value) else {
            fatalError("File value not within \"A\" and \"H\" or \"a\" and \"h\", inclusive")
        }
        self = file
    }

    /// Create an instance initialized to `value`.
    public init(extendedGraphemeClusterLiteral value: Character) {
        self.init(unicodeScalarLiteral: value)
    }

    // MARK: - Computed Properties

    /// The character value of `self` (lowercase).
    public var character: Character {
        switch self {
        case .a: return "a"
        case .b: return "b"
        case .c: return "c"
        case .d: return "d"
        case .e: return "e"
        case .f: return "f"
        case .g: return "g"
        case .h: return "h"
        }
    }

    /// The column index of `self`.
    public var index: Int {
        return rawValue - 1
    }

    /// Returns a rank from advancing `self` by `value`.
    public func advanced(by value: Int) -> File? {
        return File(rawValue: rawValue + value)
    }

    /// The next file after `self`.
    public func next() -> File? {
        return File(rawValue: (rawValue + 1))
    }

    /// The previous file to `self`.
    public func previous() -> File? {
        return File(rawValue: (rawValue - 1))
    }

    /// The opposite file of `self`.
    public func opposite() -> File {
        return File(rawValue: 9 - rawValue)!
    }

    // MARK: - Static Properties

    /// An array of all files.
    public static let all: [File] = [.a, .b, .c, .d, .e, .f, .g, .h]

    internal static let notA: Bitboard = 0xfefefefefefefefe
    internal static let notAB: Bitboard = 0xfcfcfcfcfcfcfcfc
    internal static let notH: Bitboard = 0x7f7f7f7f7f7f7f7f
    internal static let notGH: Bitboard = 0x3f3f3f3f3f3f3f3f

    // MARK: - Protocol Conformance

    /// A textual representation of `self`.
    public var description: String {
        return String(character)
    }

    /// Returns `true` if one `File` is further left than the other.
    public static func < (lhs: File, rhs: File) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }

}
