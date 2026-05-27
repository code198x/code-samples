  90 RANDOMIZE
 100 LET pop = 100: LET grain = 2800
 110 LET land = 1000: LET yr = 1
 120 CLS
 130 PRINT AT 0, 9; "*** YEARFALL ***"
 140 PRINT AT 1, 4; "Year "; yr; " of 10"
 150 PRINT AT 3, 2; "Population: "; pop
 160 PRINT AT 4, 2; "Grain: "; grain
 170 PRINT AT 5, 2; "Land: "; land; " acres"
 240 INPUT "Grain to feed: "; feed
 250 IF feed < 0 OR feed > grain THEN GO TO 240
 400 LET grain = grain - feed
 410 LET starved = 0
 420 IF feed < pop * 20 THEN LET starved = pop - INT (feed / 20)
 430 LET pop = pop - starved
 600 PRINT AT 8, 2; "Starved: "; starved
 610 PRINT AT 9, 2; "Population: "; pop
 620 PRINT AT 10, 2; "Grain left: "; grain
