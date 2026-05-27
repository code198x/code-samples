  48 RANDOMIZE
  50 LET pop = 100: LET grain = 2800
  52 LET land = 1000: LET yr = 1
  75 CLS
  80 PRINT AT 0, 9; "*** YEARFALL ***"
  82 PRINT AT 1, 4; "Year "; yr; " of 10"
  85 PRINT AT 3, 2; "Population: "; pop
  87 PRINT AT 4, 2; "Grain: "; grain
  89 PRINT AT 5, 2; "Land: "; land; " acres"
 110 INPUT "Grain to feed: "; feed
 112 IF feed < 0 OR feed > grain THEN GO TO 110
 205 LET grain = grain - feed
 210 LET starved = 0
 212 IF feed < pop * 20 THEN LET starved = pop - INT (feed / 20)
 214 LET pop = pop - starved
 300 PRINT AT 8, 2; "Starved: "; starved
 302 PRINT AT 9, 2; "Population: "; pop
 304 PRINT AT 10, 2; "Grain left: "; grain
