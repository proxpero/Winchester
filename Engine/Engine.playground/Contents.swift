import Engine

let b0 = Board()
print(b0.ascii)
print("\(b0.fen)\n\n")

let fen = "8/8/8/3Q1P2/8/8/8/8"
let b1 = Board(fen: fen)!
print(b1.ascii)

let x = b1._attacks(for: Piece.init(queen: .white), obstacles: Square.f5.bitmask)

print(x.ascii)
