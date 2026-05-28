  10 BORDER 0: PAPER 0: INK 7: CLS
  20 DATA 60,126,255,255,255,255,126,60
  30 DATA 60,126,195,195,195,195,126,60
  40 FOR u = 0 TO 1: FOR j = 0 TO 7: READ b: POKE USR CHR$ (144 + u) + j, b: NEXT j: NEXT u
  50 LET a$ = "*** LOCKSMITH ***": LET y = 5: GO SUB 9000
  60 PRINT AT 8, 2; "Crack my 4-digit code."
  70 PRINT AT 9, 2; "Each digit is 1 to 6."
  80 CIRCLE 128, 116, 8: PLOT 120, 108: DRAW 16, 0: DRAW 0, -14: DRAW -16, 0: DRAW 0, 14: PLOT 126, 100: DRAW 4, 0: DRAW 0, -4: DRAW -4, 0: DRAW 0, 4
  90 PRINT AT 11, 1; "Bull: right digit, right place"
 100 PRINT AT 12, 1; "Cow:  right digit, wrong place"
 110 PRINT AT 16, 4; "Press any key to start"
 120 PAUSE 0
 130 RANDOMIZE
 140 DIM c(4)
 150 FOR i = 1 TO 4: LET c(i) = INT (RND * 6) + 1: NEXT i
 160 CLS
 170 INVERSE 1: PRINT AT 0, 0; "      *** LOCKSMITH ***        ": INVERSE 0
 180 FOR t = 1 TO 10
 190 PRINT AT 20, 0; "Guess "; t; " of 10: ";
 200 INPUT g$
 210 IF LEN g$ <> 4 THEN GO TO 190
 220 DIM g(4)
 230 FOR i = 1 TO 4: LET g(i) = VAL g$(i): NEXT i
 240 LET bulls = 0
 250 FOR i = 1 TO 4
 260 IF g(i) = c(i) THEN LET bulls = bulls + 1
 270 NEXT i
 280 LET total = 0
 290 FOR d = 1 TO 6
 300 LET cc = 0: LET gc = 0
 310 FOR i = 1 TO 4
 320 IF c(i) = d THEN LET cc = cc + 1
 330 IF g(i) = d THEN LET gc = gc + 1
 340 NEXT i
 350 IF cc <= gc THEN LET total = total + cc
 360 IF gc < cc THEN LET total = total + gc
 370 NEXT d
 380 LET cows = total - bulls
 390 PRINT AT 2 + t, 2; g$; "  ";
 400 INK 2: FOR j = 1 TO bulls: PRINT CHR$ 144;: NEXT j
 410 INK 7: FOR j = 1 TO cows: PRINT CHR$ 145;: NEXT j
 420 INK 7
 430 INK 7
 440 BEEP 0.05, bulls * 5
 450 IF bulls = 4 THEN GO TO 480
 460 NEXT t
 470 GO TO 540
 480 CLS
 490 LET a$ = "*** LOCKSMITH ***": LET y = 6: GO SUB 9000
 500 PRINT AT 9, 6; INK 4; "Code cracked!"
 510 PRINT AT 11, 6; INK 7; "You got it in "; t; " guesses"
 520 BEEP 0.1, 10: BEEP 0.1, 15: BEEP 0.1, 20
 530 GO TO 600
 540 CLS
 550 LET a$ = "*** LOCKSMITH ***": LET y = 6: GO SUB 9000
 560 PRINT AT 9, 6; INK 2; "Out of guesses!"
 570 PRINT AT 11, 6; INK 7; "The code was ";
 580 FOR i = 1 TO 4: PRINT c(i);: NEXT i
 590 BEEP 0.3, -10
 600 PRINT AT 16, 4; "Press any key to play again"
 610 PAUSE 0
 620 GO TO 10

9000 PRINT AT y, (32 - LEN a$) / 2; BRIGHT 1; a$
9010 RETURN
