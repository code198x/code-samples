  10 BORDER 0: PAPER 0: INK 7: CLS
  20 RANDOMIZE
 110 CLS
 120 GO SUB 540
 140 LET p = INT (RND * 4) + 1
 150 GO SUB 640
 160 STOP
 540 REM --- Draw all panels ---
 550 PAPER 2
 560 FOR r = 2 TO 9: PRINT AT r, 1; "       1      ": NEXT r
 570 PAPER 1
 580 FOR r = 2 TO 9: PRINT AT r, 17; "       2      ": NEXT r
 590 PAPER 4
 600 FOR r = 12 TO 19: PRINT AT r, 1; "       3      ": NEXT r
 610 PAPER 6
 620 FOR r = 12 TO 19: PRINT AT r, 17; "       4      ": NEXT r
 630 PAPER 0: RETURN
 640 REM --- Flash panel p ---
 650 IF p = 1 THEN PAPER 2: LET pr = 2: LET pc = 1: LET note = 5
 660 IF p = 2 THEN PAPER 1: LET pr = 2: LET pc = 17: LET note = 10
 670 IF p = 3 THEN PAPER 4: LET pr = 12: LET pc = 1: LET note = 15
 680 IF p = 4 THEN PAPER 6: LET pr = 12: LET pc = 17: LET note = 20
 690 BRIGHT 1
 700 FOR r = pr TO pr + 7: PRINT AT r, pc; "              ": NEXT r
 710 BEEP 0.3, note
 720 BRIGHT 0
 730 FOR r = pr TO pr + 7: PRINT AT r, pc; "              ": NEXT r
 740 PAPER 0: RETURN
