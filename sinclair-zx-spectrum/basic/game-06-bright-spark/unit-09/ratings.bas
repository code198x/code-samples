  10 BORDER 0: PAPER 0: INK 7: CLS
  20 RANDOMIZE
  30 PRINT AT 5, 5; "*** BRIGHT SPARK ***"
  40 PRINT AT 8, 5; "Watch the panels flash."
  50 PRINT AT 9, 5; "Repeat the sequence."
  60 PRINT AT 11, 5; "Keys: 1=Red 2=Blue"
  70 PRINT AT 12, 5; "      3=Green 4=Yellow"
  80 PRINT AT 16, 5; "Press any key to start"
  90 PAUSE 0
 100 CLS
 110 GO SUB 600
 130 LET s$ = ""
 140 LET s$ = s$ + STR$ (INT (RND * 4) + 1)
 160 PAUSE 25
 170 FOR i = 1 TO LEN s$
 180 LET p = VAL s$(i)
 190 GO SUB 700
 200 PAUSE 15
 210 NEXT i
 230 PRINT AT 21, 1; "Your turn!               "
 240 FOR i = 1 TO LEN s$
 250 IF INKEY$ <> "" THEN GO TO 250
 260 IF INKEY$ = "" THEN GO TO 260
 270 LET k$ = INKEY$
 280 LET p = VAL k$
 290 IF p < 1 OR p > 4 THEN GO TO 250
 300 GO SUB 700
 310 IF k$ <> s$(i) THEN GO TO 400
 330 NEXT i
 340 PRINT AT 21, 1; "Correct!                 "
 350 PAUSE 25
 360 GO TO 140
 400 BEEP 0.5, -10
 410 LET score = LEN s$ - 1
 420 CLS
 430 PRINT AT 6, 5; "*** BRIGHT SPARK ***"
 440 PRINT AT 9, 5; "GAME OVER"
 450 PRINT AT 11, 5; "The sequence was"
 460 PRINT AT 12, 5; score; " long."
 470 PRINT AT 15, 5;
 480 IF score >= 10 THEN INK 4: PRINT "Amazing!"
 490 IF score >= 6 AND score < 10 THEN INK 5: PRINT "Good memory!"
 500 IF score >= 3 AND score < 6 THEN INK 6: PRINT "Not bad"
 510 IF score < 3 THEN INK 2: PRINT "Keep practising"
 520 INK 7
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
