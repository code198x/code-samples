10 BORDER 0: PAPER 0: INK 7: CLS
20 PRINT AT 3,10; INK 6; BRIGHT 1; "YEARFALL"
30 PRINT AT 6,1; "One settlement. Keep it alive."
35 PRINT AT 7,2; "Review every ten years."
40 PRINT AT 8,2; "Feed people. Plant a harvest."
50 PRINT AT 9,2; "Keep grain for a poor year."
60 PRINT AT 11,2; "Each person needs 3 grain."
70 PRINT AT 12,2; "Each worker farms 2 acres."
80 PRINT AT 13,2; "Each acre costs 1 seed grain."
90 PRINT AT 15,2; "Harvest: 2 to 5 per acre."
95 PRINT AT 16,2; "Full food: 5% newcomers."
100 PRINT AT 18,2; "S starts. Q quits."
110 GO SUB 8000
120 IF k$="q" OR k$="Q" THEN STOP
130 IF k$<>"s" AND k$<>"S" THEN GO TO 110
140 RANDOMIZE
200 LET pop=60: LET grain=360: LET land=100: LET yr=1: LET lost=0
201 LET joined=0: LET visit=3+INT (RND*3)
210 LET welcome=0: LET admitted=0: LET price=6+INT (RND*5)
215 IF yr=visit THEN GO TO 7000
220 LET trade=0: LET feed=3*pop
230 IF feed>grain THEN LET feed=grain
240 LET plant=land
250 IF plant>2*INT (feed/3) THEN LET plant=2*INT (feed/3)
260 IF plant>grain-feed THEN LET plant=grain-feed
270 GO SUB 2000
300 GO SUB 8000
310 IF k$="q" OR k$="Q" THEN STOP
320 IF k$="r" OR k$="R" THEN GO TO 200
330 IF k$="b" OR k$="B" THEN LET edit=1: GO SUB 6000: GO TO 270
335 IF k$="s" OR k$="S" THEN LET edit=4: GO SUB 6000: GO TO 270
340 IF k$="f" OR k$="F" THEN LET edit=2: GO SUB 6000: GO TO 270
350 IF k$="p" OR k$="P" THEN LET edit=3: GO SUB 6000: GO TO 270
360 IF k$<>" " OR ok=0 THEN GO TO 300
400 LET oldpop=pop-admitted: LET oldgrain=grain+welcome: LET oldland=land
410 LET land=land+trade: LET grain=left
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
540 IF yr/10=INT (yr/10) OR pop=0 THEN GO TO 5000
550 LET yr=yr+1: GO TO 210
2000 LET fed=INT (feed/3)
2010 IF fed>pop THEN LET fed=pop
2020 LET acres=land+trade: LET cost=trade*price: LET left=grain-cost-feed-plant
2030 LET ok=1: LET m$="All fed. Ready for harvest."
2040 IF fed<pop THEN LET m$=STR$ (pop-fed)+" people will starve."
2045 IF feed>3*pop THEN LET m$="Extra food gives no bonus."
2050 IF left<0 THEN LET ok=0: LET m$="Grain short by "+STR$ (-left)
2060 IF plant>2*fed THEN LET ok=0: LET m$="Too few fed workers."
2070 IF plant>acres THEN LET ok=0: LET m$="Planting exceeds your land."
2080 IF acres<0 THEN LET ok=0: LET m$="You cannot sell that much land."
2090 CLS
2100 PRINT AT 0,1; INK 6; BRIGHT 1; "YEARFALL"; AT 0,20; "YEAR ";yr
2110 PRINT AT 2,1; INK 5; "PEOPLE ";pop; AT 2,17; "LAND ";land
2120 PRINT AT 3,1; INK 5; "GRAIN  ";grain; AT 3,17; "PRICE ";price
2130 PRINT AT 5,1; INK 4; "PLAN"; AT 5,17; "AMOUNT"; AT 5,25; "COST"
2135 LET buy=0: LET sell=0
2136 IF trade>0 THEN LET buy=trade
2137 IF trade<0 THEN LET sell=-trade
2138 PRINT AT 6,1; "B  Buy land"; AT 6,17;buy
2140 PRINT AT 7,1; "S  Sell land"; AT 7,17;sell
2150 PRINT AT 8,1; "F  Feed grain"; AT 8,17;feed; AT 8,25;feed
2160 PRINT AT 9,1; "P  Plant acres"; AT 9,17;plant; AT 9,25;plant
2162 IF trade=0 THEN PRINT AT 10,1; INK 6; "No land bought or sold."
2164 IF trade>0 THEN PRINT AT 10,1; INK 6; "Spend ";cost;" grain on land."
2166 IF trade<0 THEN PRINT AT 10,1; INK 6; "Receive ";-cost;" grain for land."
2170 PRINT AT 11,1; INK 6; "Grain left: ";left
2180 PRINT AT 12,1; "Food needed: ";3*pop
2190 PRINT AT 13,1; "Land after trade: ";acres
2200 PRINT AT 14,1; "Fed workers can plant: ";2*fed
2210 PRINT AT 16,1; INK 6;m$
2220 IF ok=1 THEN PRINT AT 17,1; "After harvest: ";left+2*plant;" to ";left+5*plant
2230 PRINT AT 19,1; INK 5; "B/S land. F/P food/plant."
2240 PRINT AT 20,1; "SPACE harvest. R reset. Q quit."
2250 RETURN
4000 CLS
4010 PRINT AT 0,1; INK 6; BRIGHT 1; "YEARFALL"; AT 0,18; "HARVEST ";yr
4020 PRINT AT 2,1; "Yield: ";crop;" grain per acre"
4030 PRINT AT 4,1; INK 5; "GRAIN ACCOUNT"
4040 PRINT AT 6,1; "At start"; AT 6,23;oldgrain
4050 IF cost>=0 THEN PRINT AT 7,1; "Land bought: spent"; AT 7,23;cost
4055 IF cost<0 THEN PRINT AT 7,1; "Land sold: received"; AT 7,23;-cost
4060 PRINT AT 8,1; "Food spent"; AT 8,23;feed
4070 PRINT AT 9,1; "Seed spent"; AT 9,23;plant
4080 PRINT AT 10,1; "Harvest added"; AT 10,23;harvest
4085 PRINT AT 11,1; "Welcome spent"; AT 11,23;welcome
4090 PRINT AT 12,1; INK 6; "Grain in store"; AT 12,23;grain
4100 PRINT AT 14,1; "People lost: ";deaths
4110 PRINT AT 15,1; "Growth: ";newcomers;"   Guests: ";admitted
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
5065 PRINT AT 12,2; "Travellers welcomed: ";joined
5070 LET m$="A settlement still standing."
5080 IF lost=0 THEN LET m$="Nobody has starved."
5090 IF lost=0 AND grain>=3*pop THEN LET m$="Growing, with grain in reserve."
5100 IF pop=0 THEN LET m$="The settlement is empty."
5110 PRINT AT 14,1; INK 6;m$
5120 IF pop>0 THEN PRINT AT 16,2; "Next year's food: ";3*pop
5125 IF pop>0 THEN PRINT AT 18,1; INK 5; "C continues ruling."
5130 PRINT AT 19,1; "R new settlement. Q quits."
5140 GO SUB 8000
5150 IF k$="q" OR k$="Q" THEN STOP
5160 IF k$="r" OR k$="R" THEN GO TO 200
5165 IF (k$="c" OR k$="C") AND pop>0 THEN GO TO 550
5170 GO TO 5140
6000 LET d$="": LET a$="Buy acres"
6005 IF edit=4 THEN LET a$="Sell acres"
6010 IF edit=2 THEN LET a$="Feed grain"
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
6210 IF edit=1 THEN LET trade=value
6215 IF edit=4 THEN LET trade=-value
6220 IF edit=2 THEN LET feed=value
6230 IF edit=3 THEN LET plant=value
6240 RETURN
7000 LET guests=3+INT (RND*4): LET fee=6*guests: LET food=3*(pop+guests)
7010 LET can=0: IF grain>=fee+food THEN LET can=1
7020 CLS: PRINT AT 0,1; INK 6; BRIGHT 1; "YEARFALL"; AT 0,20; "YEAR ";yr
7030 PRINT AT 2,1; INK 5; "TRAVELLERS AT THE GATE"
7040 PRINT AT 4,1;guests;" people ask to settle here."
7050 PRINT AT 6,1; "Welcome costs ";fee;" grain."
7060 PRINT AT 7,1; "Grain now: ";grain
7070 PRINT AT 8,1; "After welcome: ";grain-fee
7080 PRINT AT 10,1; "People: ";pop;" -> ";pop+guests
7090 PRINT AT 11,1; "Food this year: ";food;" grain"
7100 PRINT AT 13,1; "They can work this year if fed."
7110 PRINT AT 14,1; "Each can farm 2 acres."
7120 PRINT AT 16,1; "Declining costs you nothing."
7130 IF can=1 THEN PRINT AT 18,1; INK 6; "Y welcome. N decline."
7140 IF can=0 THEN PRINT AT 18,1; INK 6; "Welcome + food unaffordable."
7150 IF can=0 THEN PRINT AT 19,1; "N declines."
7160 PRINT AT 20,1; "R restarts. Q quits."
7170 GO SUB 8000
7180 IF k$="q" OR k$="Q" THEN STOP
7190 IF k$="r" OR k$="R" THEN GO TO 200
7200 IF k$="n" OR k$="N" THEN GO TO 7240
7210 IF (k$<>"y" AND k$<>"Y") OR can=0 THEN GO TO 7170
7220 LET grain=grain-fee: LET pop=pop+guests
7230 LET welcome=fee: LET admitted=guests: LET joined=joined+guests
7240 LET visit=yr+3+INT (RND*3): GO TO 220
8000 IF INKEY$<>"" THEN GO TO 8000
8010 LET k$=INKEY$
8020 IF k$="" THEN GO TO 8010
8030 RETURN
