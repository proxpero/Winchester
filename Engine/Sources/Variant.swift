//
//  Variant.swift
//  Engine
//
//  Created by Todd Olsen on 8/4/16.
//
//

/// A chess variant that defines how a `Board` is populated or how a `Game` is played.
public enum Variant {

    // MARK: - Cases

    /// Standard chess.
    case standard

    // MARK: - Computed Properties and Functions

    /// `self` is standard variant.
    public var isStandard: Bool {
        return self == .standard
    }
    
}
