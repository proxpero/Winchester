import Endgame

let board = Board(fen: "6p1/5p2/8/3Q1P2/8/8/3n4/8")!
let origin = Square.d5
//let a = board.available(from: origin)

print(board.ascii)

let (v,a) = board.legalTargets(from: origin)

print(v.ascii)
print(a.ascii)


let q = board.attackers(targeting: Square.d2, color: .white)
print(q.ascii)

let d = board.spaces(for: .white)
print(d)


let dd = board.defendedOccupations(for: .white)

print(dd)

board.defendedOccupations(for: .white).forEach { print("\($0.key)\n\($0.value.ascii)") }

