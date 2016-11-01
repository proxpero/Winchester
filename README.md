# Winchester
A chess app written in pure swift.


                            Endgame

         ┌───────────────────────────────────────────┐
         │                                           │
         │                   Game                    │
         │                                           │
         │A game represents a series of positions. It│
         │ knows the players, the outcome, the ECO,  │
         │ and can serialize itself into PGN and EPD │
         │                 formats.                  │
         │                                           │
         └───────────────────────────────────────────┘
                               ▲
                               │
                               │
         ┌───────────────────────────────────────────┐
         │                                           │
         │                 Position                  │
         │                                           │
         │   A position takes a board and adds the   │
         │notions of player's turn, castling rights, │
         │   and the en passant square. Using this   │
         │ information it can decide whether a given │
         │              move is legal.               │
         │                                           │
         └───────────────────────────────────────────┘
                               ▲
                               │
                               │
         ┌───────────────────────────────────────────┐
         │                                           │
         │     Board (an array of 12 bitboards)      │
         │                                           │
         │A board stores one bitboard for every kind │
         │    of piece in a chess game. It knows,    │
         │  therefore, for any square on the chess   │
         │  board, whether it is empty or else what  │
         │        kind of piece occupies it.         │
         │                                           │
         └───────────────────────────────────────────┘
                               ▲
                               │
                               │
         ┌───────────────────────────────────────────┐
         │                                           │
         │             Bitboard (UInt64)             │
         │                                           │
         │A single bitboard can represent all of the │
         │ 64 squares of the chessboard say whether  │
         │      the square is occupied or not.       │
         │                                           │
         │   So, for example a single bitboard can   │
         │  provide the locations of all the black   │
         │ pawns, or the diagonals radiating from a  │
         │   particular square in four directions.   │
         │                                           │
         └───────────────────────────────────────────┘
