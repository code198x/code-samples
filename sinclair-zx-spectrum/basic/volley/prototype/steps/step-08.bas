10 BORDER 0: PAPER 0: INK 7: BRIGHT 1: CLS
15 PRINT AT 3,3;"VOLLEY";AT 5,3;"A up   Z down";AT 7,3;"Q quits. Keep the rally going.";AT 9,3;"S to serve": GO SUB 800: CLS
20 LET x=15: LET y=10: LET dx=1: LET dy=1
25 LET p=9: LET score=0
26 LET missed=0
30 PRINT AT 0,1;"VOLLEY   Returns: ";score
35 PAPER 1: FOR r=3 TO 19: PRINT AT r,2;"                            ": NEXT r
40 FOR c=2 TO 30: PRINT PAPER 5;AT 2,c;" ";AT 20,c;" ": NEXT c
50 FOR r=3 TO 19: PRINT PAPER 5;AT r,30;" ": NEXT r
90 GO SUB 500
100 PRINT AT y,x;"o"
105 LET k$=INKEY$
106 IF k$="q" THEN GO TO 900
110 PAUSE 2
125 IF k$="a" THEN IF p>3 THEN PRINT AT p+2,2;" ": LET p=p-1: PRINT PAPER 6;AT p,2;" "
126 IF k$="z" THEN IF p<17 THEN PRINT AT p,2;" ": LET p=p+1: PRINT PAPER 6;AT p+2,2;" "
200 LET nx=x+dx: LET ny=y+dy
210 IF ny=2 THEN LET dy=1: LET ny=4
220 IF ny=20 THEN LET dy=-1: LET ny=18
230 IF nx=30 THEN LET dx=-1: LET nx=28
240 IF nx=2 THEN GO SUB 600
245 IF missed=1 THEN GO TO 700
248 PRINT AT y,x;" ";AT ny,nx;"o"
250 LET x=nx: LET y=ny
300 GO TO 105
500 FOR r=p TO p+2: PRINT PAPER 6;AT r,2;" ": NEXT r
510 RETURN
600 IF ny<p THEN LET missed=1: RETURN
610 IF ny>p+2 THEN LET missed=1: RETURN
620 LET dx=1: LET nx=4: LET score=score+1: PRINT PAPER 0;AT 0,19;score
630 RETURN
700 PRINT PAPER 0;AT 21,1;"Miss. R retry, Q quit."
710 IF INKEY$<>"" THEN GO TO 710
720 LET k$=INKEY$: IF k$="q" THEN GO TO 900
730 IF k$<>"r" THEN GO TO 720
740 IF INKEY$<>"" THEN GO TO 740
750 GO TO 10
800 IF INKEY$<>"" THEN GO TO 800
810 LET k$=INKEY$: IF k$="q" THEN GO TO 900
820 IF k$<>"s" THEN GO TO 810
830 IF INKEY$<>"" THEN GO TO 830
840 RETURN
900 PRINT PAPER 0;AT 21,1;"Finished.                    ": STOP
