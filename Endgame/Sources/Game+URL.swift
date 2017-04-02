//
//  Game+URL.swift
//  Endgame
//
//  Created by Todd Olsen on 12/7/16.
//
//

import Foundation

//extension Game {
//
//    public convenience init?(with url: URL) {
//
//        guard
//            let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
//            let queryItems = components.queryItems
//        else { return nil }
//
//        self.init(with: queryItems)
//
//    }
//
//    public convenience init?(with id: String, queryItems: [URLQueryItem]) {
//
//        var white: Player = Player(name: "?")
//        var black: Player = Player(name: "?")
////        var outcome: Outcome = .undetermined
//        var date: Date = Date()
//        var moves: String = ""
//
//        for queryItem in queryItems {
//            guard let value = queryItem.value else { continue }
//            switch queryItem.name {
//            case "white": white = Player(name: value)
//            case "black": black = Player(name: value)
////            case "result": outcome = Outcome(value) ?? .undetermined
//            case "date": date = DateFormatter().date(from: value) ?? Date()
//            case "moves": moves = value
//            default: continue
//            }
//        }
//
//        self.init(whitePlayer: white, blackPlayer: black, date: date)
//
//        do {
//            try execute(sanMoves: moves.replacingOccurrences(of: ",", with: " "))
//        } catch {
//            print("ERROR: Could not make valid moves from \(moves)")
//            return nil
//        }
//
//    }
//
//    public var queryItems: [URLQueryItem] {
//
//        var items = [URLQueryItem]()
//
//        items.append(URLQueryItem(name: "white", value: whitePlayer.name))
//        items.append(URLQueryItem(name: "black", value: blackPlayer.name))
////        items.append(URLQueryItem(name: "result", value: outcome.description))
//        items.append(URLQueryItem(name: "date", value: date?.description))
//        items.append(URLQueryItem(name: "moves", value: self.sanMoves.joined(separator: ",")))
//
//        return items
//
//    }
//
//    public var url: URL {
//        var components = URLComponents()
//        components.queryItems = queryItems
//        return components.url!
//    }
//    
//}
