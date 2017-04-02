//
//  Game+Collection.swift
//  Endgame
//
//  Created by Todd Olsen on 3/21/17.
//
//

extension Game: Collection {

    public var startIndex: Int {
        return events.startIndex
    }

    public var endIndex: Int {
        return events.endIndex
    }

    public func index(after i: Int) -> Int {
        return i + 1
    }

    public subscript(position: Int) -> Event {
        return events[position]
    }
}
