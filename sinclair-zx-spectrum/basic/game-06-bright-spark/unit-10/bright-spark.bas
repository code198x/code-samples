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
 110 GO SUB 800
 120 LET s$ = ""
 130 LET s$ = s$ + STR$ (INT (RND * 4) + 1)
 140 PAUSE 25
 150 FOR i = 1 TO LEN s$
 160 LET p = VAL s$(i)
 170 GO SUB 900
 180 PAUSE 15
 190 NEXT i
 200 PRINT AT 21, 1; "Your turn!               "
 210 FOR i = 1 TO LEN s$
 220 IF INKEY$ <> "" THEN GO TO 220
 230 IF INKEY$ = "" THEN GO TO 230
 240 LET k$ = INKEY$
 250 LET p = VAL k$
 260 IF p < 1 OR p > 4 THEN GO TO 220
 270 GO SUB 900
 280 IF k$ <> s$(i) THEN GO TO 400
 290 NEXT i
 300 PRINT AT 21, 1; "Correct!                 "
 310 PAUSE 25
 320 GO TO 130
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
 530 PRINT AT 19, 5; "Press any key to play again"
 540 PAUSE 0
 550 GO TO 10
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
