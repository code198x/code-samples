450 IF deaths=0 THEN LET newcomers=INT (pop/20)
460 LET pop=pop+newcomers
530 IF k$<>" " THEN GO TO 500
540 IF yr=10 OR pop=0 THEN GO TO 5000
550 LET yr=yr+1: GO TO 220
4110 PRINT AT 15,1; "Newcomers: ";newcomers
4140 PRINT AT 19,1; "SPACE continues. R restarts."
4150 PRINT AT 20,1; "Q quits."
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
