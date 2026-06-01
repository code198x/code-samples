  10 BORDER 0: PAPER 0: INK 7: CLS
  20 RANDOMIZE
 110 CLS
 120 GO SUB 540
 140 LET s$ = ""
 150 LET s$ = s$ + STR$ (INT (RND * 4) + 1)
 170 PAUSE 25
 180 FOR i = 1 TO LEN s$
 190 LET p = VAL s$(i)
 200 GO SUB 640
 210 PAUSE 15
 220 NEXT i
 240 PRINT AT 21, 1; "Your turn!               "
 250 FOR i = 1 TO LEN s$
 260 IF INKEY$ <> "" THEN GO TO 260
 270 IF INKEY$ = "" THEN GO TO 270
 280 LET k$ = INKEY$
 290 IF k$ < "1" OR k$ > "4" THEN GO TO 260
 300 LET p = VAL k$
 310 GO SUB 640
 320 IF k$ <> s$(i) THEN PRINT AT 21, 1; "Wrong!": STOP
 340 NEXT i
 350 PRINT AT 21, 1; "Correct!                 "
 360 PAUSE 25
 370 GO TO 150
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
