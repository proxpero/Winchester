//
//  BoardCoordinate.swift
//  Endgame
//
//  Created by Todd Olsen on 8/6/16.
//
//

public protocol BoardCoordinate: RawRepresentable, Comparable {
    static var all: [Self] { get }
    var index: Int { get }
    init?(index: Int)
    func next() -> Self?
    func previous() -> Self?
    func opposite() -> Self
}

extension BoardCoordinate where Self.RawValue == Int {

    /// The row index of `self`.
    public var index: Int {
        return rawValue - 1
    }

    /// Create an instance of `Self` from a zero-based row index.
    public init?(index: Int) {
        self.init(rawValue: index + 1)
    }

    /// The next file after `self`.
    public func next() -> Self? {
        return Self(rawValue: (rawValue + 1))
    }

    /// The instance previous to `self`.
    public func previous() -> Self? {
        return Self(rawValue: (rawValue - 1))
    }

    /// The instance opposite of `self`.
    public func opposite() -> Self {
        return Self(rawValue: 9 - rawValue)!
    }

    public func to(_ other: Self) -> [Self] {
        if other > self {
            return (rawValue...other.rawValue).flatMap(Self.init(rawValue:))
        } else if other < self {
            let values = (other.rawValue...rawValue).reversed()
            return values.flatMap(Self.init(rawValue:))
        } else {
            return [self]
        }
    }

    public func between(_ other: Self) -> [Self] {
        if other > self {
            return (rawValue + 1 ..< other.rawValue).flatMap(Self.init(rawValue:))
        } else if other < self {
            let values = (other.rawValue + 1 ..< rawValue).reversed()
            return values.flatMap(Self.init(rawValue:))
        } else {
            return []
        }
    }
}
