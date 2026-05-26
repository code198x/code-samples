  10 BORDER 0: PAPER 0: INK 7: CLS
  20 RANDOMIZE
  30 REM Draw panels
  40 GO SUB 500
  50 LET s$ = ""
  60 REM Add one to the sequence
  70 LET s$ = s$ + STR$ (INT (RND * 4) + 1)
  80 PAUSE 25
  90 REM Play the sequence
 100 FOR i = 1 TO LEN s$
 110 LET p = VAL s$(i)
 120 GO SUB 600
 130 PAUSE 15
 140 NEXT i
 150 PRINT AT 21, 1; "Sequence length: "; LEN s$; "   "
 160 PAUSE 100
 170 GO TO 60
 500 REM --- Draw all panels ---
 510 PAPER 2
 520 FOR r = 2 TO 9: PRINT AT r, 1; "       1      ": NEXT r
 530 PAPER 1
 540 FOR r = 2 TO 9: PRINT AT r, 17; "       2      ": NEXT r
 550 PAPER 4
 560 FOR r = 12 TO 19: PRINT AT r, 1; "       3      ": NEXT r
 570 PAPER 6
 580 FOR r = 12 TO 19: PRINT AT r, 17; "       4      ": NEXT r
 590 PAPER 0: RETURN
 600 REM --- Flash panel p ---
 610 IF p = 1 THEN PAPER 2: LET pr = 2: LET pc = 1: LET note = 5
 620 IF p = 2 THEN PAPER 1: LET pr = 2: LET pc = 17: LET note = 10
 630 IF p = 3 THEN PAPER 4: LET pr = 12: LET pc = 1: LET note = 15
 640 IF p = 4 THEN PAPER 6: LET pr = 12: LET pc = 17: LET note = 20
 650 BRIGHT 1
 660 FOR r = pr TO pr + 7: PRINT AT r, pc; "              ": NEXT r
 670 BEEP 0.3, note
 680 BRIGHT 0
 690 FOR r = pr TO pr + 7: PRINT AT r, pc; "              ": NEXT r
 700 PAPER 0: RETURN
