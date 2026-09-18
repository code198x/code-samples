10 BORDER 0: PAPER 0: INK 7: CLS
200 LET pop=60: LET grain=360: LET land=100: LET yr=1: LET lost=0
220 LET feed=180
270 GO SUB 2000
280 STOP
2000 LET fed=INT (feed/3)
2010 IF fed>pop THEN LET fed=pop
2020 LET left=grain-feed
2030 LET ok=1: LET m$="All fed. Ready for harvest."
2040 IF fed<pop THEN LET m$=STR$ (pop-fed)+" people will starve."
2045 IF feed>3*pop THEN LET m$="Extra food gives no bonus."
2050 IF left<0 THEN LET ok=0: LET m$="Grain short by "+STR$ (-left)
2090 CLS
2100 PRINT AT 0,1; INK 6; BRIGHT 1; "YEARFALL"; AT 0,20; "YEAR ";yr
2110 PRINT AT 2,1; INK 5; "PEOPLE ";pop; AT 2,17; "LAND ";land
2120 PRINT AT 3,1; INK 5; "GRAIN  ";grain
2130 PRINT AT 5,1; INK 4; "PLAN"; AT 5,17; "AMOUNT"; AT 5,25; "COST"
2150 PRINT AT 8,1; "F  Feed grain"; AT 8,17;feed; AT 8,25;feed
2170 PRINT AT 11,1; INK 6; "Grain left: ";left
2180 PRINT AT 12,1; "Food needed: ";3*pop
2210 PRINT AT 16,1; INK 6;m$
2250 RETURN
