  10 BORDER 0: PAPER 0: INK 7: CLS
 100 RANDOMIZE
 110 LET pop = 100: LET grain = 2800
 120 LET land = 1000: LET yr = 1
 130 CLS
 140 LET a$ = "*** YEARFALL ***": LET y = 0: GO SUB 9000
 150 PRINT AT 1, 4; "Year "; yr; " of 10"
 160 PRINT AT 3, 2; "Population: "; pop
 180 PRINT AT 4, 2; "Grain: "; grain
 190 PRINT AT 5, 2; "Land: "; land; " acres"
 200 LET price = INT (RND * 10) + 17
 210 PRINT AT 6, 2; "Land price: "; price; " grain/acre"
 220 INPUT "Buy(+)/Sell(-) acres: "; trade
 230 IF trade > 0 AND trade * price > grain THEN GO TO 220
 240 IF trade < 0 AND -trade > land THEN GO TO 220
 250 LET land = land + trade: LET grain = grain - trade * price
 260 INPUT "Grain to feed: "; feed
 270 IF feed < 0 OR feed > grain THEN GO TO 260
 280 INPUT "Acres to plant: "; plant
 290 IF plant < 0 OR plant > land THEN GO TO 280
 300 IF plant > grain - feed THEN GO TO 280
 310 IF plant > pop * 10 THEN GO TO 280
 400 LET grain = grain - feed - plant
 410 LET starved = 0
 420 IF feed < pop * 20 THEN LET starved = pop - INT (feed / 20)
 430 LET pop = pop - starved
 440 LET yield = INT (RND * 5) + 1
 450 LET harvested = plant * yield
 460 LET grain = grain + harvested
 470 LET births = 0
 480 IF starved = 0 THEN LET births = INT (RND * 6) + 1
 490 LET pop = pop + births
 500 IF pop <= 0 THEN PRINT AT 14, 2; "Everyone perished!": STOP
 600 PRINT AT 8, 2; "Starved: "; starved
 610 PRINT AT 9, 2; "Harvest: "; harvested; " ("; yield; "/acre)"
 620 PRINT AT 10, 2; "Births: "; births
 630 PRINT AT 11, 2; "Pop: "; pop; "  Grain: "; grain; "  Land: "; land
 750 PRINT AT 14, 2; "Press any key..."
 760 PAUSE 0
 770 LET yr = yr + 1
 780 IF yr > 10 THEN PRINT AT 16, 2; "10 years complete! Pop: "; pop: STOP
 790 GO TO 130

9000 PRINT AT y, (32 - LEN a$) / 2; BRIGHT 1; a$
9010 RETURN
