//
//  Event.swift
//  Endgame
//
//  Created by Todd Olsen on 9/23/16.
//
//

import Foundation

/// A representation of a `PGN` event.
public struct Event {

    /// The name of the event.
    let event: String?

    /// The name of the site.
    let site: String?

    /// The starting date of the event.
    let startingDate: Date

}

extension Event: Equatable {

    /// Equatable conformance
    public static func == (lhs: Event, rhs: Event) -> Bool {
        return lhs.event == rhs.event && lhs.site == rhs.site && lhs.startingDate == rhs.startingDate
    }
}
