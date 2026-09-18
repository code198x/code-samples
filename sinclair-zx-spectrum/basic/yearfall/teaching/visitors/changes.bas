201 LET joined=0: LET visit=3+INT (RND*3)
210 LET welcome=0: LET admitted=0: LET price=6+INT (RND*5)
215 IF yr=visit THEN GO TO 7000
400 LET oldpop=pop-admitted: LET oldgrain=grain+welcome: LET oldland=land
4085 PRINT AT 11,1; "Welcome spent"; AT 11,23;welcome
4110 PRINT AT 15,1; "Growth: ";newcomers;"   Guests: ";admitted
5065 PRINT AT 12,2; "Travellers welcomed: ";joined
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
