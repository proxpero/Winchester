//
//  Position+KingStatus.swift
//  Endgame
//
//  Created by Todd Olsen on 3/26/17.
//
//

extension Position {

    /// The states a king could be in during a game.
    public enum KingStatus {

        /// Describes a state in which the king is not in check.
        case safe

        /// Describes a state in which the king is in check.
        case checked

        /// Describes a state in which the king is in ckeckmate.
        case checkmated

        /// The `SAN` representation of `self`
        var san: String {
            switch self {
            case .checkmated:
                return "#"
            case .checked: return "+"
            default:
                return ""
            }
        }

    }

}
