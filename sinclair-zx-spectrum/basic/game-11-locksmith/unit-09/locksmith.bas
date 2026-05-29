  10 BORDER 0: PAPER 0: INK 7: CLS
  20 DATA 60,126,255,255,255,255,126,60
  30 DATA 60,126,195,195,195,195,126,60
  40 FOR u = 0 TO 1: FOR j = 0 TO 7: READ b: POKE USR CHR$ (144 + u) + j, b: NEXT j: NEXT u
  50 LET a$ = "*** LOCKSMITH ***": LET y = 5: GO SUB 9000
  60 PRINT AT 8, 2; "Crack my 4-digit code."
  70 PRINT AT 9, 2; "Each digit is 1 to 6."
  80 PRINT AT 12, 1; "Cow:  right digit, wrong place"
  90 CIRCLE 128, 60, 8: PLOT 120, 52: DRAW 16, 0: DRAW 0, -14: DRAW -16, 0: DRAW 0, 14: PLOT 126, 44: DRAW 4, 0: DRAW 0, -4: DRAW -4, 0: DRAW 0, 4
 100 PRINT AT 11, 1; "Bull: right digit, right place"
 110 PRINT AT 19, 4; "Press any key to start"
 120 PAUSE 0
 130 RANDOMIZE
 140 DIM c(4)
 150 FOR i = 1 TO 4: LET c(i) = INT (RND * 6) + 1: NEXT i
 160 CLS
 190 INVERSE 1: PRINT AT 0, 0; "      *** LOCKSMITH ***        ": INVERSE 0
 200 FOR t = 1 TO 10
 210 PRINT AT 20, 0; "Guess "; t; " of 10: ";
 220 INPUT g$
 230 IF LEN g$ <> 4 THEN GO TO 210
 240 DIM g(4)
 250 FOR i = 1 TO 4: LET g(i) = VAL g$(i): NEXT i
 270 LET bulls = 0
 280 FOR i = 1 TO 4
 290 IF g(i) = c(i) THEN LET bulls = bulls + 1
 300 NEXT i
 310 LET total = 0
 320 FOR d = 1 TO 6
 330 LET cc = 0: LET gc = 0
 340 FOR i = 1 TO 4
 350 IF c(i) = d THEN LET cc = cc + 1
 360 IF g(i) = d THEN LET gc = gc + 1
 370 NEXT i
 380 IF cc <= gc THEN LET total = total + cc
 390 IF gc < cc THEN LET total = total + gc
 400 NEXT d
 410 LET cows = total - bulls
 430 PRINT AT 2 + t, 2; g$; "  ";
 440 INK 2: FOR j = 1 TO bulls: PRINT CHR$ 144;: NEXT j
 450 INK 7: FOR j = 1 TO cows: PRINT CHR$ 145;: NEXT j
 460 INK 7
 470 INK 7
 480 BEEP 0.05, bulls * 5
 490 IF bulls = 4 THEN GO TO 540
 500 NEXT t
 510 GO TO 600
 540 CLS
 550 LET a$ = "*** LOCKSMITH ***": LET y = 6: GO SUB 9000
 560 PRINT AT 9, 6; INK 4; "Code cracked!"
 570 PRINT AT 11, 6; INK 7; "You got it in "; t; " guesses"
 580 BEEP 0.1, 10: BEEP 0.1, 15: BEEP 0.1, 20
 590 GO TO 660
 600 CLS
 610 LET a$ = "*** LOCKSMITH ***": LET y = 6: GO SUB 9000
 620 PRINT AT 9, 6; INK 2; "Out of guesses!"
 630 PRINT AT 11, 6; INK 7; "The code was ";
 640 FOR i = 1 TO 4: PRINT c(i);: NEXT i
 650 BEEP 0.3, -10
 660 PRINT AT 16, 4; "Press any key to play again"
 670 PAUSE 0
 680 GO TO 10

9000 PRINT AT y, (32 - LEN a$) / 2; BRIGHT 1; a$
9010 RETURN
