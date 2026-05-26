  20 RANDOMIZE
 100 CLS
 110 GO SUB 800
 120 LET s$ = ""
 130 LET s$ = s$ + STR$ (INT (RND * 4) + 1)
 140 PAUSE 25
 150 FOR i = 1 TO LEN s$
 160 LET p = VAL s$(i)
 170 GO SUB 900
 180 PAUSE 15
 190 NEXT i
 195 STOP
 800 REM --- Draw all panels ---
 810 PAPER 2
 820 FOR r = 2 TO 9: PRINT AT r, 1; "       1      ": NEXT r
 830 PAPER 1
 840 FOR r = 2 TO 9: PRINT AT r, 17; "       2      ": NEXT r
 850 PAPER 4
 860 FOR r = 12 TO 19: PRINT AT r, 1; "       3      ": NEXT r
 870 PAPER 6
 880 FOR r = 12 TO 19: PRINT AT r, 17; "       4      ": NEXT r
 890 PAPER 0: RETURN
 900 REM --- Flash panel p ---
 910 IF p = 1 THEN PAPER 2: LET pr = 2: LET pc = 1: LET note = 5
 920 IF p = 2 THEN PAPER 1: LET pr = 2: LET pc = 17: LET note = 10
 930 IF p = 3 THEN PAPER 4: LET pr = 12: LET pc = 1: LET note = 15
 940 IF p = 4 THEN PAPER 6: LET pr = 12: LET pc = 17: LET note = 20
 950 BRIGHT 1
 960 FOR r = pr TO pr + 7: PRINT AT r, pc; "              ": NEXT r
 970 BEEP 0.3, note
 980 BRIGHT 0
 990 FOR r = pr TO pr + 7: PRINT AT r, pc; "              ": NEXT r
 995 PAPER 0: RETURN
