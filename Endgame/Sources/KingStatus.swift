//
//  KingStatus.swift
//  Endgame
//
//  Created by Todd Olsen on 3/20/17.
//
//

/// The states a king could be in during a game.
public enum KingStatus {
    case safe
    case checked
    case checkmated

    var algebraicAnnotation: String {
        switch self {
        case .checkmated:
            return "#"
        case .checked: return "+"
        default:
            return ""
        }
    }
}
