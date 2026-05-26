  10 BORDER 0: PAPER 0: INK 7: CLS
  20 RANDOMIZE
  30 GO SUB 800
  40 LET s$ = ""
  50 LET s$ = s$ + STR$ (INT (RND * 4) + 1)
  60 PAUSE 25
  70 FOR i = 1 TO LEN s$
  80 LET p = VAL s$(i)
  90 GO SUB 900
 100 PAUSE 15
 110 NEXT i
 120 PRINT AT 21, 1; "Your turn!               "
 130 FOR i = 1 TO LEN s$
 140 IF INKEY$ <> "" THEN GO TO 140
 150 IF INKEY$ = "" THEN GO TO 150
 160 LET k$ = INKEY$
 170 LET p = VAL k$
 180 IF p < 1 OR p > 4 THEN GO TO 140
 190 GO SUB 900
 200 IF k$ <> s$(i) THEN GO TO 300
 210 NEXT i
 220 PRINT AT 21, 1; "Correct!                 "
 230 PAUSE 25
 240 GO TO 50
 300 BEEP 0.5, -10
 310 LET score = LEN s$ - 1
 320 CLS
 330 PRINT AT 8, 5; "GAME OVER"
 340 PRINT AT 10, 5; "The sequence was"
 350 PRINT AT 11, 5; score; " long."
 360 PRINT AT 14, 5;
 370 IF score >= 10 THEN INK 4: PRINT "Amazing!"
 380 IF score >= 6 AND score < 10 THEN INK 5: PRINT "Good memory!"
 390 IF score >= 3 AND score < 6 THEN INK 6: PRINT "Not bad"
 400 IF score < 3 THEN INK 2: PRINT "Keep practising"
 410 INK 7
 420 PRINT AT 18, 5; "Press any key to play again"
 430 PAUSE 0
 440 GO TO 10
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
