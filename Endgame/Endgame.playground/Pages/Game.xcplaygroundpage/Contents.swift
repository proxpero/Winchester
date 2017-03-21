
import Endgame

let moves = "1.e4 e5 2.f4 exf4 3.Bc4 Qh4+ 4.Kf1 b5 5.Bxb5 Nf6 6.Nf3 Qh6"
let pgn = try! PGN(parse: moves)
let game = Game(pgn: pgn)

for p in game {
    print(p.sanMove)
}

print(game[0])

