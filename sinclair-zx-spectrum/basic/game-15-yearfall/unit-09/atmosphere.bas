  10 BORDER 0: PAPER 0: INK 7: CLS
  20 PRINT AT 4, 9; "*** YEARFALL ***"
  25 PRINT AT 7, 4; "Rule a kingdom for 10 years."
  27 PRINT AT 8, 4; "Feed your people."
  30 PRINT AT 9, 4; "Plant crops. Trade land."
  32 PRINT AT 10, 4; "Grow or collapse."
  35 PRINT AT 14, 4; "Press any key to begin"
  40 PAUSE 0
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
 107 IF trade > 0 AND trade * price > grain THEN BEEP 0.1, -5: GO TO 105
 108 IF trade < 0 AND -trade > land THEN BEEP 0.1, -5: GO TO 105
 109 LET land = land + trade: LET grain = grain - trade * price
 110 INPUT "Grain to feed: "; feed
 112 IF feed < 0 OR feed > grain THEN BEEP 0.1, -5: GO TO 110
 115 INPUT "Acres to plant: "; plant
 117 IF plant < 0 OR plant > land THEN BEEP 0.1, -5: GO TO 115
 118 IF plant > grain - feed THEN BEEP 0.1, -5: GO TO 115
 119 IF plant > pop * 10 THEN BEEP 0.1, -5: GO TO 115
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
 240 IF pop <= 0 THEN GO TO 500
 300 CLS
 310 PRINT AT 0, 9; "*** YEARFALL ***"
 312 PRINT AT 1, 4; "Year "; yr; " report"
 315 PRINT AT 3, 2; "Harvest: "; harvested; " grain"
 317 PRINT AT 4, 2; "("; yield; " grain per acre)"
 320 IF starved > 0 THEN PRINT AT 6, 2; INK 2; starved; " people starved.": BEEP 0.2, -10
 322 IF starved = 0 THEN PRINT AT 6, 2; INK 4; "Nobody starved."
 325 IF births > 0 THEN PRINT AT 7, 2; INK 4; births; " newcomers arrived."
 327 IF births = 0 THEN PRINT AT 7, 2; "No newcomers this year."
 330 PRINT AT 9, 2; "Population: "; pop
 332 PRINT AT 10, 2; "Grain: "; grain
 334 PRINT AT 11, 2; "Land: "; land; " acres"
 340 PRINT AT 14, 2; "Press any key for next year"
 345 PAUSE 0
 350 LET yr = yr + 1
 355 IF yr > 10 THEN GO TO 500
 360 GO TO 75
 500 CLS
 510 PRINT AT 4, 9; "*** YEARFALL ***"
 512 IF pop <= 0 THEN PRINT AT 7, 4; INK 2; "Your kingdom collapsed.": BEEP 0.5, -15: GO TO 550
 515 PRINT AT 7, 4; "After 10 years..."
 517 PRINT AT 9, 2; "Population: "; pop
 519 PRINT AT 10, 2; "Grain: "; grain
 521 PRINT AT 11, 2; "Land: "; land; " acres"
 524 IF pop >= 200 THEN PRINT AT 13, 4; INK 4; "Wise Ruler!": GO TO 540
 526 IF pop >= 150 THEN PRINT AT 13, 4; INK 4; "Prosperity!": GO TO 540
 528 IF pop >= 100 THEN PRINT AT 13, 4; INK 6; "Steady Hand.": GO TO 540
 530 IF pop >= 50 THEN PRINT AT 13, 4; INK 6; "Hard Times.": GO TO 540
 532 PRINT AT 13, 4; INK 2; "The People Suffer."
 540 BEEP 0.1, 10: BEEP 0.1, 15: BEEP 0.1, 20
 550 PAUSE 0: STOP
