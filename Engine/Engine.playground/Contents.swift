import Engine

let file1 = String()
    + "[Event \"London\"]\n"
    + "[Site \"London\"]\n"
    + "[Date \"1851.??.??\"]\n"
    + "[EventDate \"?\"]\n"
    + "[Round \"?\"]\n"
    + "[Result \"1-0\"]\n"
    + "[White \"Adolf Anderssen\"]\n"
    + "[Black \"Kieseritzky\"]\n"
    + "[ECO \"C33\"]\n"
    + "[WhiteElo \"?\"]\n"
    + "[BlackElo \"?\"]\n"
    + "[PlyCount \"45\"]\n"
    + "\n"
    + "1.e4 e5 2.f4 exf4 3.Bc4 Qh4+ 4.Kf1 b5 5.Bxb5 Nf6 6.Nf3 Qh6 7.d3 Nh5 8.Nh4 Qg5\n"
    + "9.Nf5 c6 10.g4 Nf6 11.Rg1 cxb5 12.h4 Qg6 13.h5 Qg5 14.Qf3 Ng8 15.Bxf4 Qf6\n"
    + "16.Nc3 Bc5 17.Nd5 Qxb2 18.Bd6 Bxg1 19. e5 Qxa1+ 20. Ke2 Na6 21.Nxg7+ Kd8\n"
    + "22.Qf6+ Nxf6 23.Be7# 1-0\n"


let moves = ["1. e4 e5", "2. f4 exf4", "3. Bc4 Qh4+", "4. Kf1 b5", "5. Bxb5 Nf6", "6. Nf3 Qh6", "7. d3 Nh5", "8. Nh4 Qg5", "9. Nf5 c6", "10. g4 Nf6", "11. Rg1 cxb5", "12. h4 Qg6", "13. h5 Qg5", "14. Qf3 Ng8", "15. Bxf4 Qf6", "16. Nc3 Bc5", "17. Nd5 Qxb2", "18. Bd6 Bxg1", "19. e5 Qxa1+", "20. Ke2 Na6", "21. Nxg7+ Kd8", "22. Qf6+ Nxf6", "23. Be7#"]

let pgn = try! PGN(parse: file1)
let result = "[Event \"London\"]\n[Site \"London\"]\n[Date \"1851.??.??\"]\n[Round \"?\"]\n[White \"Adolf Anderssen\"]\n[Black \"Kieseritzky\"]\n[Result \"1-0\"]\n[ECO \"C33\"]\n[WhiteElo \"?\"]\n[BlackElo \"?\"]\n[EventDate \"?\"]\n[PlyCount \"45\"]\n"
assert(pgn.exportTagPairs == result)

pgn.fullMoves
pgn.exportFullMoves

let file2 = String()
    + "[Event \"F/S Return Match\"]\n"
    + "[Site \"Belgrade, Serbia Yugoslavia|JUG\"]\n"
    + "[Date \"1992.11.04\"]\n"
    + "[Round \"29\"]\n"
    + "[White \"Fischer, Robert J.\"]\n"
    + "[Black \"Spassky, Boris V.\"]\n"
    + "[Result \"1/2-1/2\"]\n"
    + "\n"
    + "1. e4 e5 2. Nf3 Nc6 3. Bb5 a6 {This opening is called the Ruy Lopez.}\n"
    + "4. Ba4 Nf6 5. O-O Be7 6. Re1 b5 7. Bb3 d6 8. c3 O-O 9. h3 Nb8  10. d4 Nbd7\n"
    + "11. c4 c6 12. cxb5 axb5 13. Nc3 Bb7 14. Bg5 b4 15. Nb1 h6 16. Bh4 c5 17. dxe5\n"
    + "Nxe4 18. Bxe7 Qxe7 19. exd6 Qf6 20. Nbd2 Nxd6 21. Nc4 Nxc4 22. Bxc4 Nb6\n"
    + "23. Ne5 Rae8 24. Bxf7+ Rxf7 25. Nxf7 Rxe1+ 26. Qxe1 Kxf7 27. Qe3 Qg5 28. Qxg5\n"
    + "hxg5 29. b3 Ke6 30. a3 Kd6 31. axb4 cxb4 32. Ra5 Nd5 33. f3 Bc8 34. Kf2 Bf5\n"
    + "35. Ra7 g6 36. Ra6+ Kc5 37. Ke1 Nf4 38. g3 Nxh3 39. Kd2 Kb5 40. Rd6 Kc5 41. Ra6\n"
    + "Nf2 42. g4 Bd3 43. Re6 1/2-1/2\n"

let pgn2 = try! PGN(parse: file2)
let result2 = "[Event \"F/S Return Match\"]\n[Site \"Belgrade, Serbia Yugoslavia|JUG\"]\n[Date \"1992.11.04\"]\n[Round \"29\"]\n[White \"Fischer, Robert J.\"]\n[Black \"Spassky, Boris V.\"]\n[Result \"1/2-1/2\"]\n"
assert(pgn2.exportTagPairs == result2)
pgn2.exportTagPairs
