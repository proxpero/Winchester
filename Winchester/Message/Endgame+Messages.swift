//
//  Endgame+Messages.swift
//  Winchester
//
//  Created by Todd Olsen on 11/20/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import Foundation
import Messages
import Endgame

extension PGN {

    init(with queryItems: [URLQueryItem]) {

        var tags: [Tag: String] = [:]
        var moves: [String] = []
        for queryItem in queryItems {
            guard let value = queryItem.value else { continue }
            switch queryItem.name {
            case "white": tags[Tag.white] = value
            case "black": tags[Tag.black] = value
            case "result": tags[Tag.result] = value
            case "date": tags[Tag.date] = value
            case "moves": moves = value.components(separatedBy: ",")
            default: continue
            }
        }
        self = PGN(tagPairs: tags, moves: moves)
    }

    var queryItems: [URLQueryItem] {

        var items = [URLQueryItem]()

        if let white = self[Tag.white] {
            items.append(URLQueryItem(name: "white", value: white))
        }

        if let black = self[Tag.black] {
            items.append(URLQueryItem(name: "black", value: black))
        }

        if let result = self[Tag.result] {
            items.append(URLQueryItem(name: "result", value: result))
        }

        if let date = self[Tag.date] {
            items.append(URLQueryItem(name: "date", value: date))
        }

        items.append(URLQueryItem(name: "moves", value: sanMoves().joined(separator: ",")))

        return items

    }
}

extension Game {
    
    convenience init?(with message: MSMessage?) {
        guard let messageURL = message?.url else { return nil }
        guard let urlComponents = NSURLComponents(url: messageURL, resolvingAgainstBaseURL: false), let queryItems = urlComponents.queryItems
            else { return nil }
        self.init(with: queryItems)
    }
}
