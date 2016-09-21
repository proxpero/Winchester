import Engine

let sampleFens = [
    "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR",
    "1k1r4/pp1b1R2/3q2pp/4p3/2B5/4Q3/PPP2B2/2K5",
    "r1b1k3/p2p1Nr1/n2b3p/3pp1pP/2BB1p2/P3P2R/Q1P3P1/R3K1N1",
    "r1b1k2r/pp1n1ppp/2p1p3/q5B1/1b1P4/P1n1PN2/1P1Q1PPP/2R1KB1R",
    "5rk1/p5pp/2p3p1/1p1pR3/3P2P1/2N5/PP3n2/2KB4",
    "rnbq1rk1/ppp3pp/3bpn2/3p1p2/2PP4/2NBPN2/PP3PPP/R1BQK2R",
    "8/5R2/8/r2KB3/6k1/8/8/8",
    "rnbqkbnr/pppppp2/7p/6pP/8/8/PPPPPPP1/RNBQKBNR",
    "rnbqkbnr/pp1ppppp/8/8/2pP4/2P2N2/PP2PPPP/RNBQKB1R",
    "rnbqkbnr/pp1ppppp/2p5/8/6P1/2P5/PP1PPP1P/RNBQKBNR",
    "rnb1kbnr/ppq1pppp/2pp4/8/6P1/2P5/PP1PPPBP/RNBQK1NR",
    "rn2kbnr/p1q1ppp1/1ppp3p/8/4B1b1/2P4P/PPQPPP2/RNB1K1NR",
    "rnkq1bnr/p3ppp1/1ppp3p/3B4/6b1/2PQ3P/PP1PPP2/RNB1K1NR",
    "rn1q1bnr/3kppp1/2pp3p/pp6/1P2b3/2PQ1N1P/P2PPPB1/RNB1K2R",
    "rnkq1bnr/4pp2/2pQ2pp/pp6/1P5N/2P4P/P2PPP2/RNB1KB1b",
    "rn3b1r/1kq1p3/2pQ1npp/Pp6/4b3/2PPP2P/P4P2/RNB1KB2",
    "r4br1/8/k1p2npp/Ppn1p3/P7/2PPP1qP/4bPQ1/RNB1KB2",
    "rnbqk1nr/p2p3p/1p5b/2pPppp1/8/P7/1PPQPPPP/RNB1KBNR",
    "rnb1k2r/pp1p1p1p/1q1P4/2pnpPp1/6P1/2N5/PP1BP2P/R2QKBNR",
    "1n4kr/2B4p/2nb2b1/ppp5/P1PpP3/3P4/5K2/1N1R4",
    "r2n3r/1bNk2pp/6P1/pP3p2/3pPqnP/1P1P1p1R/2P3B1/Q1B1bKN1"
]
for fen in sampleFens {
    let b = Board(fen: fen)!
    print(b.ascii)
}