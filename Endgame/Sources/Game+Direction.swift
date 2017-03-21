//
//  Game+Direction.swift
//  Endgame
//
//  Created by Todd Olsen on 3/17/17.
//
//

public enum Direction: Equatable {
    case undo
    case redo

    public var isUndo: Bool {
        switch self {
        case .undo:
            return true
        default:
            return false
        }
    }

    public var isRedo: Bool {
        switch self {
        case .redo:
            return true
        default:
            return false
        }
    }

    public init?(currentIndex: Int?, newIndex: Int?) {

        switch (currentIndex, newIndex) {
        case (nil, nil): return nil
        case (nil, _): self = .redo
        case (_, nil): self = .undo
        default:
            self = (currentIndex! < newIndex!) ? .undo : .redo
        }
        
    }
}
