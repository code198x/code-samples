20 RANDOMIZE
30 PRINT AT 3,10; INK 5; BRIGHT 1; "C I P H E R"
40 PRINT AT 7,3; "Find the hidden word."
50 PRINT AT 9,2; "Reveal every matching letter."
60 PRINT AT 11,3; "Seven mistakes per word."
70 PRINT AT 13,3; "Repeat guesses cost nothing."
80 PRINT AT 17,3; "S starts. Q quits."
90 GO SUB 8000
100 IF k$="q" THEN STOP
110 IF k$<>"s" THEN GO TO 90
200 LET wins=0: LET losses=0: LET round=0: LET last=0: LET total=24
210 LET pick=INT (RND*total)+1
220 IF pick=last THEN GO TO 210
230 LET last=pick: LET round=round+1: RESTORE 9000
240 FOR i=1 TO pick: READ w$: NEXT i
780 IF k$=" " THEN GO TO 210
9000 DATA "WINDOW","BOTTLE","KETTLE","LADDER","RABBIT","GARDEN"
9010 DATA "POCKET","CANDLE","PILLOW","BUTTON","BASKET","BRIDGE"
9020 DATA "ORANGE","SILVER","HAMMER","ROCKET","JACKET","FOREST"
9030 DATA "CAMERA","MARKET","CARPET","SHELL","TUNNEL","STREAM"
