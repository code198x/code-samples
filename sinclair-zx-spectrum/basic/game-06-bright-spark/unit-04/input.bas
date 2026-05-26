  10 BORDER 0: PAPER 0: INK 7: CLS
  20 RANDOMIZE
  30 GO SUB 500
  40 LET s$ = ""
  50 REM Add one to the sequence
  60 LET s$ = s$ + STR$ (INT (RND * 4) + 1)
  70 PAUSE 25
  80 REM Play the sequence
  90 FOR i = 1 TO LEN s$
 100 LET p = VAL s$(i)
 110 GO SUB 600
 120 PAUSE 15
 130 NEXT i
 140 REM Player repeats
 150 PRINT AT 21, 1; "Your turn!               "
 160 FOR i = 1 TO LEN s$
 170 LET k$ = ""
 180 IF INKEY$ <> "" THEN GO TO 180
 190 IF INKEY$ = "" THEN GO TO 190
 200 LET k$ = INKEY$
 210 LET p = VAL k$
 220 IF p < 1 OR p > 4 THEN GO TO 180
 230 GO SUB 600
 240 IF k$ <> s$(i) THEN GO TO 400
 250 NEXT i
 260 PRINT AT 21, 1; "Correct!                 "
 270 PAUSE 25
 280 GO TO 50
 400 REM Game over
 410 BEEP 0.5, -10
 420 PRINT AT 21, 1; "Wrong! Sequence was "; LEN s$ - 1; " long"
 430 STOP
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
