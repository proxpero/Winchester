//
//  Opponent.swift
//  Winchester
//
//  Created by Todd Olsen on 1/3/17.
//  Copyright © 2017 Todd Olsen. All rights reserved.
//

import Foundation
import Endgame

let defaultStoreName = "group.com.proxpero.winchester.shared"

public class OpponentStore {

    private let _suiteName: String
    private var _store: Dictionary<String, Opponent>

    private func synchronize() {
        guard let suite = UserDefaults.init(suiteName: _suiteName) else { return }
        suite.set(self.toDictionary, forKey: "opponents")
    }

    public static var defaultStore: OpponentStore = {
        guard let store = OpponentStore.store(with: defaultStoreName) else { fatalError("Could not create default opponent store") }
        return store
    }()

    public static func store(with suiteName: String) -> OpponentStore? {
        guard let suite = UserDefaults.init(suiteName: suiteName) else { return nil }
        let opponentsEntry = suite.dictionary(forKey: "opponents") ?? {
            let result = Dictionary<String, Any>()
            suite.set(result, forKey: "opponents")
            return result
        }()

        return OpponentStore(dictionary: opponentsEntry, suiteName: suiteName)
    }

    private init(dictionary: Dictionary<String, Any>, suiteName: String) {
        var result = Dictionary<String, Opponent>()
        for entry in dictionary {
            guard let dict = entry.value as? Dictionary<String, Any>, let opponent = Opponent(dictionary: dict) else { continue }
            result[entry.key] = opponent
        }
        self._suiteName = suiteName
        self._store = result
    }

    private var toDictionary: Dictionary<String, Any> {
        var result = Dictionary<String, Any>()
        for entry in _store {
            result[entry.key] = entry.value.toDictionary
        }
        return result
    }

    public var opponents: Dictionary<String, Opponent> {
        return _store
    }

    public subscript(key: String) -> Opponent? {
        get {
            return _store[key]
        }
        set {
            _store[key] = newValue
            synchronize()
        }
    }

    @discardableResult
    public func createOpponent(_ name: String, for key: String) -> Opponent {
        let opponent: Opponent
        defer {
            self[key] = opponent
            synchronize()
        }
        opponent = Opponent(name: name, urls: self[key]?.urls ?? [])
        return opponent
    }

}

public struct Opponent {

    public let name: String
    public let urls: [URL]

    public var games: [Game] {
        return urls.flatMap { Game(with: $0) }
    }

    public init(name: String, urls: [URL] = []) {
        self.name = name
        self.urls = urls
    }

    public func appending(url: URL) -> Opponent {
        return Opponent(name: name, urls: urls + [url])
    }
}

extension Opponent {

    public init?(dictionary: Dictionary<String, Any>) {
        guard let name = dictionary["name"] as? String,
            let urls = dictionary["urls"] as? [String]
            else { return nil }
        self.name = name
        self.urls = urls.flatMap { URL.init(string: $0) }
    }

    public var toDictionary: Dictionary<String, Any> {
        var result = Dictionary<String, Any>()
        result["name"] = name
        result["urls"] = urls.map { $0.absoluteString }
        return result
    }

}

extension Player {
    public init(opponent: Opponent) {
        self.init(name: opponent.name)
    }
}
