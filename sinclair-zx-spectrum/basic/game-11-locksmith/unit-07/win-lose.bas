  10 BORDER 0: PAPER 0: INK 7: CLS
 130 RANDOMIZE
 140 DIM c(4)
 150 FOR i = 1 TO 4: LET c(i) = INT (RND * 6) + 1: NEXT i
 160 CLS
 170 PRINT AT 14, 2; "Code: ";
 180 FOR i = 1 TO 4: PRINT c(i);: NEXT i
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
 430 PRINT AT 2 + t, 2; g$; "  "; bulls; " bull  "; cows; " cow"
 490 IF bulls = 4 THEN GO TO 540
 500 NEXT t
 510 GO TO 600
 540 CLS
 550 LET a$ = "*** LOCKSMITH ***": LET y = 6: GO SUB 9000
 560 PRINT AT 9, 6; "Code cracked!"
 570 PRINT AT 11, 6; "You got it in "; t; " guesses"
 580 BEEP 0.1, 10: BEEP 0.1, 15: BEEP 0.1, 20
 590 STOP
 600 CLS
 610 LET a$ = "*** LOCKSMITH ***": LET y = 6: GO SUB 9000
 620 PRINT AT 9, 6; "Out of guesses!"
 630 PRINT AT 11, 6; "The code was ";
 640 FOR i = 1 TO 4: PRINT c(i);: NEXT i
 650 BEEP 0.3, -10

9000 PRINT AT y, (32 - LEN a$) / 2; BRIGHT 1; a$
9010 RETURN
