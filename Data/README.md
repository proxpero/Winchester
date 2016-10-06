# "40H-PGN" databases.

copyright (c) 2014-16 by Norman Pollock. All rights reserved.

These PGN database files are freeware. They consist of games 
available in the Public Domain on the Internet that were further
edited by Norman Pollock. 

No warranty, expressed or implied, is made that the information 
provided in readme-pgn-db.not is accurate. 

No warranty, expressed or implied, is made that the information in
each game description is accurate. This includes names of players,
game moves and game results.

No warranty, expressed or implied, is made as to the worthiness of 
these files for computer or chess usage. 

The user bears full responsibility for any consequences from the use 
or misuse of these files. The editor is not responsible for any
damages or losses of any kind.

These database files can be freely distributed provided they are 
distributed "as is". The editor is not responsible for any changes 
made by others.

-------------

"40H-PGN-databases" is divided into two sections: "gm" databases 
containing human games, and "cc" databases containing computer
chess (engine-engine) games.

-------------

=================
"gm" databases
=================

High quality databases of long time-control games between top 
Human players. There are 4 files: gm1830.pgn, gm1931.pgn, 
gm1981.pgn and gm2006.pgn.

Double games (same moves as an existing game) and many near-double 
games were excluded.

Certain types of games have been excluded, for example, Rapid and 
Blitz games. Tag data was used to determine such games and might 
not indicate all such games.

Games were checked for technical errors using "joined" by Andreas 
Stable and "pgn-extract" by David Barnes. Games with errors were 
excluded.

Games were checked for major blunders in the first 25 moves using 
"Game Analyser" by Thomas McBurney. Games with blunders were 
excluded.

"ECO" codes were recalculated using extended "SCID" ECO codes. 

Games have full-move formatting on each line.

Comments have been removed. 

Excessive disambiguity has been removed.

Games were sorted in the following order: ECO, WhitePlayer, 
BlackPlayer, Result, Date.

-------------

(1) gm1830.pgn

Games were played from 1834 to 1930. 

No blindfold, simultaneous, exhibition, or cable games.
 
Exclusions based on Tag data which might not indicate 
all such games.

Number of games = 15,361
Number of players = 414
Number of clusters = 2 (see note below)
Minimum player score = 20.0%
Minimum Elo = none
Minimum occurrences each player = 8
Minimum plies each game = 51
Beginning date of games = 1834.01.01
Ending date of games = 1930.08.01
Version = 2015.07.15

Note: "De la Bourdonnais, Louis C." and "MacDonnell, Alexander" 
only played each other.

-------------

(2) gm1931.pgn

Games were played from 1931 to 1980. 

No blitz, blindfold, simultaneous, exhibition, radio or telex 
games. Exclusions based on Tag data which might not indicate 
all such games.

Number of games = 47,054
Number of players = 1,073
Number of clusters = 1
Minimum player score = 20.0%
Minimum Elo = none
Minimum occurrences each player = 8
Minimum plies each game = 51
Beginning date of games = 1931.01.01
Ending date of games = 1980.10.01
Version = 2015.07.15

-------------

(3) gm1981.pgn

Games were played from 1981 to 2005. 

No blitz, rapid, blindfold, simultaneous, exhibition, playoff,
KO, Internet or correspondence games. Exclusions based 
on Tag data which might not indicate all such games.

Number of games = 99,980
Number of players = 1,232
Number of clusters = 1
Minimum player score = 20.0%
Minimum Elo = 2450
Minimum occurrences each player = 12
Minimum plies each game = 51
Beginning date of games = 1981.01.01
Ending date of games = 2005.12.31
Version = 2016.02.06

-------------

(4) gm2006.pgn

Games were played from 2006 to 2016. 

No blitz, rapid, tiebreak, blindfold, simultaneous, exhibition, 
playoff, KO, Internet or correspondence games. Exclusions based 
on Tag data which might not indicate all such games.

Number of games = 87,310
Number of players = 1,161
Number of clusters = 1
Minimum player score = 20.0%
Minimum Elo = 2475
Minimum occurrences each player = 20
Minimum plies each game = 51
Beginning date of games = 2006.01.01
Ending date of games = 2016.08.31
Version = 2016.08.31

=================
"cc" databases
=================

High quality databases of selected medium time-control games between 
top computer chess engines. There are 2 databases: cc01.pgn (from 
CCRL 40/40) and cc02.pgn (from CEGT 40/20). 

Filtering was then done to ensure the engines/games have the 
following characteristics:

1. 64-bit 4CPU engines 
2. medium time control
3. high rated engines
4. no games with the same moves
5. no games between different versions or derivatives of the 
   same engine

"ECO" codes were recalculated using extended "SCID" ECO codes. 

"Elo" values were recalculated using "EloStat 1.3" with starting
value = 3000. 

Comments have been removed. 

Excessive disambiguity has been removed.

Games were sorted in the following order: ECO, WhitePlayer, 
BlackPlayer, Result, Date.

Games have full-move formatting on each line.
  
Note: Most computer engine-engine games are "in book" for at least 
the first 8 moves.  

-------------

(1) cc01.pgn

Games from CCRL 40/40

Number of games = 26,278
Number of engines = 73
Number of clusters = 1
Minimum player score = 30.0%
Base Elo = 3000
Minimum Elo (recalculated) = 2975
Minimum occurrences each engine = 100
Minimum plies each game = 51
Maximum plies each game = 500
Beginning date of games = 2011.01.01
Ending date of games = 2016.08.31
Version = 2016.09.01

-------------

(2) cc02.pgn

Games from CEGT 40/20

Number of games = 29,186
Number of engines = 39
Number of clusters = 1
Minimum player score = 30.0%
Base Elo = 3000
Minimum Elo (recalculated) = 2975
Minimum occurrences each engine = 100
Minimum plies each game = 51
Maximum plies each game = 500
Beginning date of games = 2011.01.01
Ending date of games = 2016.08.31
Version = 2016.08.31

=================

Latest versions are at:

   http://hoflink.com/~npollock/40H.html
   
# readme for "40H-EPD-databases".

"40H-EPD-databases" is copyright (c) 2014-6 by Norman Pollock. 
All rights reserved.

"40H-EPD-databases" contains the "EPD" databases: 
"40H-openings_6moves", "40H-openings_8moves", "mateIn1", 
"mateIn2", "mateIn3", "mateIn4", "mateIn5" and "mateIn6".

These databases are freeware. They consist of chess positions 
available in the Public Domain on the Internet and were edited 
by Norman Pollock.

No warranty, expressed or implied, is made that the information 
provided in readme-epd-db.not or in the positions, is accurate. 

No warranty, expressed or implied, is made as to the worthiness 
of these files for computer or chess usage. 

The user bears full responsibility for any consequences from the 
use or misuse of these files. The editor is not responsible for 
any damages or losses of any kind.

These databases can be freely distributed provided they are 
distributed "as is". The editor is not responsible for any 
changes made by others.

--------------

The "40H-EPD" utility program "epdConvert" can be used to convert 
an "epd" database into a "pgn" database. This process can be helpful 
if you are using chess software that does not handle "epd" databases
properly.

--------------

"40H-openings_6moves" and "40H-openings_8moves" contain popular 
opening positions that occurred after 6 and 8 moves respectively. 

Each position occurred in at least 12 games in the "40H-PGN" 
databases.

There are 3,304 positions in "40H-openings_6moves".

There are 3,710 positions in "40H-openings_8moves".

Positions are not composed.

No duplicate positions.

All false "En Passant" target squares were removed. 

If you are running an engine-engine tournament with either of 
these files as the opening "EPD" book, it is strongly recommended 
that you "reverse the colors" for each position (if available).

----------

"mateIn1.epd", "mateIn2.epd", "mateIn3.epd", "mateIn4.epd", 
"mateIn5.epd" and "mateIn6.epd" contain positional problems whose
solution is a checkmate in the number of moves indicated in the
filename.

There are a total of 4464 positions in the "mateInX" files. 

Positions are not composed.

No duplicate positions.

All false "En Passant" target squares were removed. 

Each record contains a suggested "best move" and a suggested 
"principle variation". Where there are multiple mate solutions,
a "best move" is indicated for each solution, but only one
"principle variation" is listed.

"ChestUCI v5.2" by Franz Huber, based on "CHEST v3.19" by
Heiner Marxen, was used in the "Arena" GUI to obtain the 
"best move" and the "principle variation".

-------------

The latest version is at:

  http://hoflink.com/~npollock/40H.html
  
-------------

current version: 2016.05.08
  
