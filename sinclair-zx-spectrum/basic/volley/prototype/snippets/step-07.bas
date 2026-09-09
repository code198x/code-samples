10 BORDER 0: PAPER 0: INK 7: BRIGHT 1: CLS
15 PRINT AT 3,3;"VOLLEY";AT 5,3;"A up   Z down";AT 7,3;"Q quits. Keep the rally going.";AT 9,3;"S to serve": GO SUB 800: CLS
35 PAPER 1: FOR r=3 TO 19: PRINT AT r,2;"                            ": NEXT r
40 FOR c=2 TO 30: PRINT PAPER 5;AT 2,c;" ";AT 20,c;" ": NEXT c
50 FOR r=3 TO 19: PRINT PAPER 5;AT r,30;" ": NEXT r
500 FOR r=p TO p+2: PRINT PAPER 6;AT r,2;" ": NEXT r
620 LET dx=1: LET nx=4: LET score=score+1: PRINT PAPER 0;AT 0,19;score
700 PRINT PAPER 0;AT 21,1;"Miss. R retry, Q quit."
900 PRINT PAPER 0;AT 21,1;"Finished.                    ": STOP
