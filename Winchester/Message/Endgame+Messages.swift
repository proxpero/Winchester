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


extension Game {

    convenience init?(message: MSMessage?) {
        guard let messageURL = message?.url else { return nil }
        guard let urlComponents = NSURLComponents(url: messageURL, resolvingAgainstBaseURL: false), let queryItems = urlComponents.queryItems
            else { return nil }

        guard let item = queryItems.filter({ $0.name == "moves" }).first, let moves = item.value else {
            return nil
        }
        let pgn = PGN(tagPairs: Dictionary<String, String>(), moves: moves.components(separatedBy: ","))
        self.init(pgn: pgn)
    }

    var url: URL {
        var components = URLComponents()
        components.queryItems = [queryItem]
        return components.url!
    }

    var queryItem: URLQueryItem {
        return URLQueryItem(name: "moves", value: pgn.sanMoves().joined(separator: ","))
    }

}
