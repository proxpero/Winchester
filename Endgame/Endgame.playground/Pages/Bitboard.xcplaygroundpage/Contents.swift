import Endgame

let square = Square.a1
let obstacle = Square.a7

let x = square.bitboard.filled(toward: .north, until: obstacle.bitboard)


print(x.ascii)


