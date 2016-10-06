//
//  Event.swift
//  Engine
//
//  Created by Todd Olsen on 9/23/16.
//
//

import Foundation

public struct Event {

    let event: String?
    let site: String?
    let startingDate: Date

}

extension Event: Equatable {
    public static func == (lhs: Event, rhs: Event) -> Bool {
        return lhs.event == rhs.event && lhs.site == rhs.site && lhs.startingDate == rhs.startingDate
    }
}
