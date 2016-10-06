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

print(game.currentPosition.ascii)
print(game.sanMoves)

print(game.currentPosition.ascii)

game.reverse(to: game.startIndex)
print(game.currentPosition.ascii)
game.advance(to: game.lastIndex)
print(game.currentPosition.ascii)

game.reverse(to: 15)
print(game.currentPosition.ascii)

game.advance(to: game.lastIndex)
print(game.currentPosition.ascii)




