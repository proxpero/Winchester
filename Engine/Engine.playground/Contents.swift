import Engine
import Foundation

class Delegate: GameDelegate {

    func game(_: Game, didExecute move: Move, with capture: Capture?, with promotion: Piece?) {
        print("move: \(move), capture: \(capture), promotion: \(promotion)")
    }

    func game(_: Game, didAdvance items: [HistoryItem]) {
        print(#function)
        print(items.count)
    }

    func game(_: Game, didReverse items: [HistoryItem]) {
        print(#function)
        print(items.count)
    }

}

let url = Bundle.main.url(forResource: "test", withExtension: "pgn")!
let string = try! String(contentsOf: url)
let pgn = try! PGN(parse: string)
let game = Game(pgn: pgn)
let delegate = Delegate()
game.delegate = delegate



