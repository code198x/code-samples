  10 BORDER 0: PAPER 0: INK 7: CLS
  20 LET a$ = "*** YEARFALL ***": LET y = 4: GO SUB 9000
  30 PRINT AT 7, 4; "Rule a kingdom for 10 years."
  40 PRINT AT 8, 4; "Feed your people."
  50 PRINT AT 9, 4; "Plant crops. Trade land."
  60 PRINT AT 10, 4; "Grow or collapse."
  70 PLOT 104, 84: DRAW 0, -20: DRAW 8, 0: DRAW 0, 8: DRAW 8, 0: DRAW 0, -8: DRAW 16, 0: DRAW 0, 8: DRAW 8, 0: DRAW 0, -8: DRAW 8, 0: DRAW 0, 20: DRAW -48, 0
  80 PRINT AT 14, 4; "Press any key to begin"
  90 PAUSE 0
 100 RANDOMIZE
 110 LET pop = 100: LET grain = 2800
 120 LET land = 1000: LET yr = 1
 130 CLS
 140 INVERSE 1: PRINT AT 0, 0; "    *** YEARFALL ***  Year "; yr; "   ": INVERSE 0
 160 PRINT AT 3, 2; "Population: "; pop; "    "
 170 PRINT AT 2, 2;: INK 4: FOR j = 1 TO INT (pop / 10): PRINT CHR$ 143;: NEXT j: FOR j = INT (pop / 10) + 1 TO 30: PRINT " ";: NEXT j: INK 7
 180 PRINT AT 4, 2; "Grain: "; grain
 190 PRINT AT 5, 2; "Land: "; land; " acres"
 200 LET price = INT (RND * 10) + 17
 210 PRINT AT 6, 2; "Land price: "; price; " grain/acre"
 220 INPUT "Buy(+)/Sell(-) acres: "; trade
 230 IF trade > 0 AND trade * price > grain THEN BEEP 0.1, -5: GO TO 220
 240 IF trade < 0 AND -trade > land THEN BEEP 0.1, -5: GO TO 220
 250 LET land = land + trade: LET grain = grain - trade * price
 260 INPUT "Grain to feed: "; feed
 270 IF feed < 0 OR feed > grain THEN BEEP 0.1, -5: GO TO 260
 280 INPUT "Acres to plant: "; plant
 290 IF plant < 0 OR plant > land THEN BEEP 0.1, -5: GO TO 280
 300 IF plant > grain - feed THEN BEEP 0.1, -5: GO TO 280
 310 IF plant > pop * 10 THEN BEEP 0.1, -5: GO TO 280
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
 640 INVERSE 1: PRINT AT 0, 0; "    *** YEARFALL ***  Year "; yr; "   ": INVERSE 0
 660 PRINT AT 3, 2; "Harvest: "; harvested; " grain"
 670 PRINT AT 4, 2; "("; yield; " grain per acre)"
 680 IF starved > 0 THEN BORDER 2: PRINT AT 6, 2; INK 2; starved; " people starved.": BEEP 0.2, -10: BORDER 0
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
 790 GO TO 130
 900 CLS
 910 LET a$ = "*** YEARFALL ***": LET y = 4: GO SUB 9000
 920 IF pop <= 0 THEN PRINT AT 7, 4; INK 2; "Your kingdom collapsed.": BEEP 0.5, -15: GO TO 1030
 930 PRINT AT 7, 4; "After 10 years..."
 940 PRINT AT 9, 2; "Population: "; pop
 950 PRINT AT 10, 2; "Grain: "; grain
 960 PRINT AT 11, 2; "Land: "; land; " acres"
 970 IF pop >= 200 THEN PRINT AT 13, 4; INK 4; "Wise Ruler!": GO TO 1020
 980 IF pop >= 150 THEN PRINT AT 13, 4; INK 4; "Prosperity!": GO TO 1020
 990 IF pop >= 100 THEN PRINT AT 13, 4; INK 6; "Steady Hand.": GO TO 1020
1000 IF pop >= 50 THEN PRINT AT 13, 4; INK 6; "Hard Times.": GO TO 1020
1010 PRINT AT 13, 4; INK 2; "The People Suffer."
1020 BEEP 0.1, 10: BEEP 0.1, 15: BEEP 0.1, 20
1030 PRINT AT 18, 4; "Press any key to play again"
1040 PAUSE 0
1050 GO TO 10

9000 PRINT AT y, (32 - LEN a$) / 2; BRIGHT 1; a$
9010 RETURN
