import Engine
import Foundation

//let url = Bundle.main.url(forResource: "mateIn1", withExtension: "epd")!
//let epds = try! String(contentsOf: url)
//    .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
//    .components(separatedBy: "\r\n")
//    .flatMap { EPD(parse: $0) }
//
//print(epds)

let game = Game()
try! game.execute(sanMoves: "e4 c5 Nc3 Nc6 g3")
//print(game.eco)


let eco = game.eco!.name
    .replacingOccurrences(of: game.eco!.code.rawValue, with: "")
    .trimmingCharacters(in: CharacterSet.whitespaces.union(CharacterSet.punctuationCharacters))
print(">\(eco)<")