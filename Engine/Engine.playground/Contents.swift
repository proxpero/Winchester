import Engine
import Foundation

let url = Bundle.main.url(forResource: "mateIn1", withExtension: "epd")!
let epds = try! String(contentsOf: url)
    .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    .components(separatedBy: "\r\n")
    .flatMap { EPD(parse: $0) }

print(epds)
