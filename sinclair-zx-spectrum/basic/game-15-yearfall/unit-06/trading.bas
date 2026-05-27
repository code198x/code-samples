  48 RANDOMIZE
  50 LET pop = 100: LET grain = 2800
  52 LET land = 1000: LET yr = 1
  75 CLS
  80 PRINT AT 0, 9; "*** YEARFALL ***"
  82 PRINT AT 1, 4; "Year "; yr; " of 10"
  85 PRINT AT 3, 2; "Population: "; pop
  87 PRINT AT 4, 2; "Grain: "; grain
  89 PRINT AT 5, 2; "Land: "; land; " acres"
  91 LET price = INT (RND * 10) + 17
  93 PRINT AT 6, 2; "Land price: "; price; " grain/acre"
 105 INPUT "Buy(+)/Sell(-) acres: "; trade
 107 IF trade > 0 AND trade * price > grain THEN GO TO 105
 108 IF trade < 0 AND -trade > land THEN GO TO 105
 109 LET land = land + trade: LET grain = grain - trade * price
 110 INPUT "Grain to feed: "; feed
 112 IF feed < 0 OR feed > grain THEN GO TO 110
 115 INPUT "Acres to plant: "; plant
 117 IF plant < 0 OR plant > land THEN GO TO 115
 118 IF plant > grain - feed THEN GO TO 115
 119 IF plant > pop * 10 THEN GO TO 115
 205 LET grain = grain - feed - plant
 210 LET starved = 0
 212 IF feed < pop * 20 THEN LET starved = pop - INT (feed / 20)
 214 LET pop = pop - starved
 220 LET yield = INT (RND * 5) + 1
 222 LET harvested = plant * yield
 224 LET grain = grain + harvested
 230 LET births = 0
 232 IF starved = 0 THEN LET births = INT (RND * 6) + 1
 234 LET pop = pop + births
 240 IF pop <= 0 THEN PRINT AT 14, 2; "Everyone perished!": STOP
 300 PRINT AT 8, 2; "Starved: "; starved
 302 PRINT AT 9, 2; "Harvest: "; harvested; " ("; yield; "/acre)"
 304 PRINT AT 10, 2; "Births: "; births
 306 PRINT AT 11, 2; "Pop: "; pop; "  Grain: "; grain; "  Land: "; land
 340 PRINT AT 14, 2; "Press any key..."
 345 PAUSE 0
 350 LET yr = yr + 1
 355 IF yr > 10 THEN PRINT AT 16, 2; "10 years complete! Pop: "; pop: STOP
 360 GO TO 75
