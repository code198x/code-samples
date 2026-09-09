15 PRINT AT 5,3;"A up   Z down";AT 7,3;"Q quits. Keep the rally going.";AT 9,3;"S to serve": GO SUB 800: CLS
25 LET p=9: LET score=0
30 PRINT AT 0,1;"VOLLEY   Returns: ";score
106 IF k$="q" THEN GO TO 900
620 LET dx=1: LET nx=4: LET score=score+1: PRINT AT 0,19;score
700 PRINT AT 21,1;"Miss. R retry, Q quit."
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
900 PRINT AT 21,1;"Finished.                    ": STOP
