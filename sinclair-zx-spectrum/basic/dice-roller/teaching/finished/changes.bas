20 RANDOMIZE: DIM t(6): DIM p(6)
30 LET n=0: LET pn=0: LET b=60: LET h$="####################": LET z$="                    "
100 CLS: PRINT AT 2,8; INK 5; BRIGHT 1; "DICE ROLLER"
110 PRINT AT 5,2; "Explore a six-sided die."
120 PRINT AT 7,2; "Choose a fresh batch:"
130 PRINT AT 9,5; "1       12 rolls"
140 PRINT AT 10,5; "2       60 rolls"
150 PRINT AT 11,5; "3      300 rolls"
160 PRINT AT 12,5; "4     1200 rolls"
170 PRINT AT 15,2; "Then repeat, or add more."
180 PRINT AT 17,2; "Samples vary. Compare shares."
190 PRINT AT 20,2; "1-4 chooses. Q quits."
200 GO SUB 8000
210 IF k$="q" THEN STOP
220 IF k$<"1" OR k$>"4" THEN GO TO 200
230 LET b=12
240 IF k$="2" THEN LET b=60
250 IF k$="3" THEN LET b=300
260 IF k$="4" THEN LET b=1200
270 LET add=0: GO TO 400
300 GO SUB 8000
310 IF k$="q" THEN STOP
320 IF k$="n" THEN GO TO 100
330 IF k$="r" THEN LET add=0: GO TO 400
340 IF k$="a" AND n+b<=9600 THEN LET add=1: GO TO 400
350 IF k$="a" THEN PRINT AT 19,1; "9600 limit. R starts fresh.     "
360 GO TO 300
400 LET pn=n: FOR j=1 TO 6: LET p(j)=t(j): NEXT j
410 IF add=0 THEN DIM t(6): LET n=0
420 LET target=n+b: LET done=0
425 LET pace=1: IF b>=300 THEN LET pace=10
460 IF i/pace=INT (i/pace) OR i=1 THEN GO SUB 1100
730 PRINT AT 20,1; "R new ";b;"  A +";b;"  N sizes"
740 PRINT AT 21,1; "Q quits."
750 GO TO 300
1010 PRINT AT 1,14; "Prev ";pn
1030 PRINT AT 4,1; INK 5; "FACE  COUNT   NOW%     PREV%"
1060 IF pn>0 THEN PRINT AT row,24;INT (1000*p(j)/pn+0.5)/10
1070 IF pn=0 THEN PRINT AT row,24;"--"
8000 LET k$=INKEY$
8010 IF INKEY$<>"" THEN GO TO 8010
8020 LET k$=INKEY$: IF k$="" THEN GO TO 8020
8030 IF CODE k$>=65 AND CODE k$<=90 THEN LET k$=CHR$ (CODE k$+32)
8040 RETURN
