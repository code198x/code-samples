10 BORDER 0: PAPER 0: INK 7: CLS
140 RANDOMIZE
200 LET pop=60: LET grain=360: LET land=100: LET yr=1: LET lost=0
220 LET feed=3*pop
230 IF feed>grain THEN LET feed=grain
240 LET plant=land
250 IF plant>2*INT (feed/3) THEN LET plant=2*INT (feed/3)
260 IF plant>grain-feed THEN LET plant=grain-feed
270 GO SUB 2000
300 GO SUB 8000
310 IF k$="q" OR k$="Q" THEN STOP
320 IF k$="r" OR k$="R" THEN GO TO 200
340 IF k$="f" OR k$="F" THEN LET edit=2: GO SUB 6000: GO TO 270
350 IF k$="p" OR k$="P" THEN LET edit=3: GO SUB 6000: GO TO 270
360 IF k$<>" " OR ok=0 THEN GO TO 300
400 LET oldpop=pop: LET oldgrain=grain: LET oldland=land
410 LET grain=left
420 LET deaths=pop-fed: LET lost=lost+deaths: LET pop=fed
430 LET crop=2+INT (RND*4): LET harvest=plant*crop: LET grain=grain+harvest
440 LET newcomers=0
450 IF deaths=0 THEN LET newcomers=INT (pop/20)
460 LET pop=pop+newcomers
470 GO SUB 4000
500 GO SUB 8000
510 IF k$="q" OR k$="Q" THEN STOP
520 IF k$="r" OR k$="R" THEN GO TO 200
530 IF k$<>" " THEN GO TO 500
540 IF yr=10 OR pop=0 THEN GO TO 5000
550 LET yr=yr+1: GO TO 220
2000 LET fed=INT (feed/3)
2010 IF fed>pop THEN LET fed=pop
2020 LET left=grain-feed-plant
2030 LET ok=1: LET m$="All fed. Ready for harvest."
2040 IF fed<pop THEN LET m$=STR$ (pop-fed)+" people will starve."
2045 IF feed>3*pop THEN LET m$="Extra food gives no bonus."
2050 IF left<0 THEN LET ok=0: LET m$="Grain short by "+STR$ (-left)
2060 IF plant>2*fed THEN LET ok=0: LET m$="Too few fed workers."
2070 IF plant>land THEN LET ok=0: LET m$="Planting exceeds your land."
2090 CLS
2100 PRINT AT 0,1; INK 6; BRIGHT 1; "YEARFALL"; AT 0,20; "YEAR ";yr
2110 PRINT AT 2,1; INK 5; "PEOPLE ";pop; AT 2,17; "LAND ";land
2120 PRINT AT 3,1; INK 5; "GRAIN  ";grain
2130 PRINT AT 5,1; INK 4; "PLAN"; AT 5,17; "AMOUNT"; AT 5,25; "COST"
2150 PRINT AT 8,1; "F  Feed grain"; AT 8,17;feed; AT 8,25;feed
2160 PRINT AT 9,1; "P  Plant acres"; AT 9,17;plant; AT 9,25;plant
2170 PRINT AT 11,1; INK 6; "Grain left: ";left
2180 PRINT AT 12,1; "Food needed: ";3*pop
2200 PRINT AT 14,1; "Fed workers can plant: ";2*fed
2210 PRINT AT 16,1; INK 6;m$
2230 PRINT AT 19,1; INK 5; "F/P edit food and planting."
2240 PRINT AT 20,1; "SPACE harvest. R reset. Q quit."
2250 RETURN
4000 CLS
4010 PRINT AT 0,1; INK 6; BRIGHT 1; "YEARFALL"; AT 0,18; "HARVEST ";yr
4020 PRINT AT 2,1; "Yield: ";crop;" grain per acre"
4030 PRINT AT 4,1; INK 5; "GRAIN ACCOUNT"
4040 PRINT AT 6,1; "At start"; AT 6,23;oldgrain
4060 PRINT AT 8,1; "Food spent"; AT 8,23;feed
4070 PRINT AT 9,1; "Seed spent"; AT 9,23;plant
4080 PRINT AT 10,1; "Harvest added"; AT 10,23;harvest
4090 PRINT AT 12,1; INK 6; "Grain in store"; AT 12,23;grain
4100 PRINT AT 14,1; "People lost: ";deaths
4110 PRINT AT 15,1; "Newcomers: ";newcomers
4120 PRINT AT 16,1; INK 5; "People ";oldpop;" -> ";pop
4130 PRINT AT 17,1; INK 5; "Land   ";oldland;" -> ";land
4140 PRINT AT 19,1; "SPACE continues. R restarts."
4150 PRINT AT 20,1; "Q quits."
4160 RETURN
5000 CLS
5010 PRINT AT 2,10; INK 6; BRIGHT 1; "YEARFALL"
5020 PRINT AT 5,2; "Years completed: ";yr
5030 PRINT AT 7,2; "People: ";pop;" (started at 60)"
5040 PRINT AT 8,2; "Grain:  ";grain
5050 PRINT AT 9,2; "Land:   ";land
5060 PRINT AT 11,2; "People lost over run: ";lost
5070 LET m$="A settlement still standing."
5080 IF lost=0 THEN LET m$="Nobody has starved."
5090 IF lost=0 AND grain>=3*pop THEN LET m$="Growing, with grain in reserve."
5100 IF pop=0 THEN LET m$="The settlement is empty."
5110 PRINT AT 14,1; INK 6;m$
5120 IF pop>0 THEN PRINT AT 16,2; "Next year's food: ";3*pop
5130 PRINT AT 19,1; "R new settlement. Q quits."
5140 GO SUB 8000
5150 IF k$="q" OR k$="Q" THEN STOP
5160 IF k$="r" OR k$="R" THEN GO TO 200
5170 GO TO 5140
6000 LET d$="": LET a$="Feed grain"
6020 IF edit=3 THEN LET a$="Plant acres"
6030 PRINT AT 19,0; "                                "; AT 20,0; "                                "; AT 21,0; "                               "
6040 PRINT AT 19,1; INK 6;a$;": ";d$;"_     "
6050 PRINT AT 20,1; "Digits, ENTER. DELETE erases."
6060 PRINT AT 21,1; "X cancels. Blank keeps plan."
6070 GO SUB 8000
6080 IF k$="x" OR k$="X" THEN RETURN
6090 IF CODE k$=13 AND d$="" THEN RETURN
6100 IF CODE k$=13 THEN GO TO 6200
6110 IF CODE k$=12 AND LEN d$>0 THEN LET d$=d$( TO LEN d$-1): GO TO 6040
6130 IF CODE k$<48 OR CODE k$>57 THEN GO TO 6070
6140 IF LEN d$>=4 THEN GO TO 6070
6170 LET d$=d$+k$: GO TO 6040
6200 LET value=VAL d$
6220 IF edit=2 THEN LET feed=value
6230 IF edit=3 THEN LET plant=value
6240 RETURN
8000 IF INKEY$<>"" THEN GO TO 8000
8010 LET k$=INKEY$
8020 IF k$="" THEN GO TO 8010
8030 RETURN
