//
//  Game+PGN.swift
//  Endgame
//
//  Created by Todd Olsen on 11/3/16.
//
//

import Foundation

extension Game {

    // MARK: - PGN
    // MARK: Public Initializer

    /// Creates a new chess game.
    ///
    /// - parameter pgn: A PGN instance.
    public convenience init(pgn: PGN) {

        let game = Game()

        game.whitePlayer = Player(name: pgn[PGN.Tag.white], kind: pgn[PGN.Tag.whiteType], elo: pgn[PGN.Tag.whiteElo])
        game.blackPlayer = Player(name: pgn[PGN.Tag.black], kind: pgn[PGN.Tag.blackType], elo: pgn[PGN.Tag.blackElo])
        game.outcome = pgn.outcome

        let sanMoves = pgn.sanMoves()

        do {
            try game.execute(sanMoves: sanMoves.joined(separator: " "))
        } catch {
            fatalError("could not parse san moves: \(sanMoves)")
        }
        self.init(game: game)
    }

    private static var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy.MM.dd"
        return df
    }()

    /// Returns a `Dictionary` where `Key` = `PGN.Tag` and `Value` = `String` of
    /// the PGN tag pairs describing `self`.
    public func tagPairs() -> Dictionary<PGN.Tag, String> {

        var pairs: Dictionary<PGN.Tag, String> = [:]
        pairs[.white] = whitePlayer.name
        pairs[.black] = blackPlayer.name
        pairs[.result] = outcome.description
        if let eco = eco {
            pairs[.eco] = eco.code.rawValue
        }
        pairs[.date] = Game.dateFormatter.string(from: date)
        return pairs
    }

    /**
     Returns the PGN representation of `self`.
     */
    public var pgn: PGN {
        return PGN(tagPairs: tagPairs(), moves: self.map({ $0.sanMove }))
    }

}
