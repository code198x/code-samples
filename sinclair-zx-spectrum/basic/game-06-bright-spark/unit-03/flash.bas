  10 BORDER 0: PAPER 0: INK 7: CLS
  20 RANDOMIZE
 100 CLS
 110 GO SUB 600
 130 LET p = INT (RND * 4) + 1
 140 GO SUB 700
 150 STOP
 600 REM --- Draw all panels ---
 610 PAPER 2
 620 FOR r = 2 TO 9: PRINT AT r, 1; "       1      ": NEXT r
 630 PAPER 1
 640 FOR r = 2 TO 9: PRINT AT r, 17; "       2      ": NEXT r
 650 PAPER 4
 660 FOR r = 12 TO 19: PRINT AT r, 1; "       3      ": NEXT r
 670 PAPER 6
 680 FOR r = 12 TO 19: PRINT AT r, 17; "       4      ": NEXT r
 690 PAPER 0: RETURN
 700 REM --- Flash panel p ---
 710 IF p = 1 THEN PAPER 2: LET pr = 2: LET pc = 1: LET note = 5
 720 IF p = 2 THEN PAPER 1: LET pr = 2: LET pc = 17: LET note = 10
 730 IF p = 3 THEN PAPER 4: LET pr = 12: LET pc = 1: LET note = 15
 740 IF p = 4 THEN PAPER 6: LET pr = 12: LET pc = 17: LET note = 20
 750 BRIGHT 1
 760 FOR r = pr TO pr + 7: PRINT AT r, pc; "              ": NEXT r
 770 BEEP 0.3, note
 780 BRIGHT 0
 790 FOR r = pr TO pr + 7: PRINT AT r, pc; "              ": NEXT r
 800 PAPER 0: RETURN
