10 BORDER 0: PAPER 0: INK 7: BRIGHT 0: CLS
20 RANDOMIZE: DIM t(6)
30 LET n=0: LET b=12: LET done=0: LET h$="####################": LET z$="                    "
430 GO SUB 1000
435 PRINT AT 19,1; "Rolling... Q stops this batch."
440 FOR i=1 TO b
450 LET d=INT (RND*6)+1: LET t(d)=t(d)+1: LET n=n+1: LET done=done+1
460 GO SUB 1100
470 LET k$=INKEY$
480 IF k$="q" OR k$="Q" THEN GO TO 600
490 NEXT i
600 GO SUB 1000: GO SUB 1100
720 PRINT AT 19,1; "Samples vary; no fairness proof."
725 IF done<b THEN PRINT AT 19,1; "Stopped early. Counts kept.     "
750 STOP
1000 CLS: PRINT AT 0,9; INK 5; BRIGHT 1; "DICE ROLLER"
1020 PRINT AT 2,1; "Bars 0-100%; rounded to 5%."
1030 PRINT AT 4,1; INK 5; "FACE  COUNT   NOW%"
1040 FOR j=1 TO 6: LET row=5+2*(j-1)
1050 PRINT AT row,2;j; AT row+1,5;CHR$ 91; AT row+1,26;CHR$ 93
1080 NEXT j: PRINT AT 18,1; "Fair model: about 16.7% each."
1090 RETURN
1100 PRINT AT 1,1; "Rolls ";n;"   "
1110 FOR j=1 TO 6
1120 LET row=5+2*(j-1): LET pc=INT (1000*t(j)/n+0.5)/10
1130 PRINT AT row,7;t(j);"    "; AT row,15;pc;"   "
1140 LET width=INT (20*t(j)/n+0.5)
1150 PRINT AT row+1,6; INK 5;h$(TO width);z$(TO 20-width)
1160 NEXT j
1170 PRINT AT 20,1; "Batch ";done;" / ";b;"     "
1180 RETURN
