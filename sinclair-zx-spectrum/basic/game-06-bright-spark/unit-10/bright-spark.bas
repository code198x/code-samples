  10 BORDER 0: PAPER 0: INK 7: CLS
  20 RANDOMIZE
  30 PRINT AT 5, 5; BRIGHT 1; "*** BRIGHT SPARK ***"
  40 PRINT AT 8, 5; "Watch the panels flash."
  50 PRINT AT 9, 5; "Repeat the sequence."
  60 PRINT AT 11, 5; "Keys: 1=Red 2=Blue"
  70 PRINT AT 12, 5; "      3=Green 4=Yellow"
  80 PRINT AT 16, 5; "Press any key to start"
  90 PRINT AT 6, 11; PAPER 2; "  "; PAPER 1; "  "; PAPER 4; "  "; PAPER 6; "  "
 100 PAUSE 0
 110 CLS
 120 GO SUB 500
 130 LET s$ = ""
 140 LET s$ = s$ + STR$ (INT (RND * 4) + 1)
 150 PAUSE 25
 160 FOR i = 1 TO LEN s$
 170 LET p = VAL s$(i)
 180 GO SUB 600
 190 PAUSE 15
 200 NEXT i
 210 PRINT AT 21, 1; "Your turn!               "
 220 FOR i = 1 TO LEN s$
 230 IF INKEY$ <> "" THEN GO TO 230
 240 IF INKEY$ = "" THEN GO TO 240
 250 LET k$ = INKEY$
 260 LET p = VAL k$
 270 IF p < 1 OR p > 4 THEN GO TO 230
 280 GO SUB 600
 290 IF k$ <> s$(i) THEN GO TO 340
 300 NEXT i
 310 PRINT AT 21, 1; "Correct!                 "
 320 PAUSE 25
 330 GO TO 140
 340 BEEP 0.5, -10
 350 LET score = LEN s$ - 1
 360 CLS
 370 PRINT AT 6, 5; "*** BRIGHT SPARK ***"
 380 PRINT AT 9, 5; "GAME OVER"
 390 PRINT AT 11, 5; "The sequence was"
 400 PRINT AT 12, 5; score; " long."
 410 PRINT AT 15, 5;
 420 IF score >= 10 THEN INK 4: PRINT "Amazing!"
 430 IF score >= 6 AND score < 10 THEN INK 5: PRINT "Good memory!"
 440 IF score >= 3 AND score < 6 THEN INK 6: PRINT "Not bad"
 450 IF score < 3 THEN INK 2: PRINT "Keep practising"
 460 INK 7
 470 PRINT AT 19, 5; "Press any key to play again"
 480 PAUSE 0
 490 GO TO 10
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

9000 PRINT AT y, (32 - LEN a$) / 2; a$
9010 RETURN
