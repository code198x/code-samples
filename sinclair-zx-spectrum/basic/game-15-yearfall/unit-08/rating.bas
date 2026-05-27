  90 RANDOMIZE
 100 LET pop = 100: LET grain = 2800
 110 LET land = 1000: LET yr = 1
 120 CLS
 130 PRINT AT 0, 9; "*** YEARFALL ***"
 140 PRINT AT 1, 4; "Year "; yr; " of 10"
 150 PRINT AT 3, 2; "Population: "; pop
 160 PRINT AT 4, 2; "Grain: "; grain
 170 PRINT AT 5, 2; "Land: "; land; " acres"
 180 LET price = INT (RND * 10) + 17
 190 PRINT AT 6, 2; "Land price: "; price; " grain/acre"
 200 INPUT "Buy(+)/Sell(-) acres: "; trade
 210 IF trade > 0 AND trade * price > grain THEN GO TO 200
 220 IF trade < 0 AND -trade > land THEN GO TO 200
 230 LET land = land + trade: LET grain = grain - trade * price
 240 INPUT "Grain to feed: "; feed
 250 IF feed < 0 OR feed > grain THEN GO TO 240
 260 INPUT "Acres to plant: "; plant
 270 IF plant < 0 OR plant > land THEN GO TO 260
 280 IF plant > grain - feed THEN GO TO 260
 290 IF plant > pop * 10 THEN GO TO 260
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
 500 IF pop <= 0 THEN GO TO 900
 600 CLS
 640 PRINT AT 0, 9; "*** YEARFALL ***"
 650 PRINT AT 1, 4; "Year "; yr; " report"
 660 PRINT AT 3, 2; "Harvest: "; harvested; " grain"
 670 PRINT AT 4, 2; "("; yield; " grain per acre)"
 680 IF starved > 0 THEN PRINT AT 6, 2; INK 2; starved; " people starved."
 690 IF starved = 0 THEN PRINT AT 6, 2; INK 4; "Nobody starved."
 700 IF births > 0 THEN PRINT AT 7, 2; INK 4; births; " newcomers arrived."
 710 IF births = 0 THEN PRINT AT 7, 2; "No newcomers this year."
 720 PRINT AT 9, 2; "Population: "; pop
 730 PRINT AT 10, 2; "Grain: "; grain
 740 PRINT AT 11, 2; "Land: "; land; " acres"
 750 PRINT AT 14, 2; "Press any key for next year"
 760 PAUSE 0
 770 LET yr = yr + 1
 780 IF yr > 10 THEN GO TO 900
 790 GO TO 120
 900 CLS
 910 PRINT AT 4, 9; "*** YEARFALL ***"
 920 IF pop <= 0 THEN PRINT AT 7, 4; INK 2; "Your kingdom collapsed.": GO TO 1030
 930 PRINT AT 7, 4; "After 10 years..."
 940 PRINT AT 9, 2; "Population: "; pop
 950 PRINT AT 10, 2; "Grain: "; grain
 960 PRINT AT 11, 2; "Land: "; land; " acres"
 970 IF pop >= 200 THEN PRINT AT 13, 4; INK 4; "Wise Ruler!": GO TO 1030
 980 IF pop >= 150 THEN PRINT AT 13, 4; INK 4; "Prosperity!": GO TO 1030
 990 IF pop >= 100 THEN PRINT AT 13, 4; INK 6; "Steady Hand.": GO TO 1030
1000 IF pop >= 50 THEN PRINT AT 13, 4; INK 6; "Hard Times.": GO TO 1030
1010 PRINT AT 13, 4; INK 2; "The People Suffer."
1030 PAUSE 0: STOP
