//
//  Game+Collection.swift
//  Endgame
//
//  Created by Todd Olsen on 3/21/17.
//
//

extension Game: Collection {

    public var startIndex: Int {
        return _items.startIndex
    }

    public var endIndex: Int {
        return _items.endIndex
    }

    public func index(after i: Int) -> Int {
        precondition(i < endIndex)
        return i + 1
    }

    public subscript(position: Int) -> HistoryItem {

        get {
            return _items[position]
        }

    }


}
