  10 BORDER 0: PAPER 0: INK 7: CLS
  20 PRINT AT 5, 8; "*** LOCKSMITH ***"
  30 PRINT AT 8, 2; "Crack my 4-digit code."
  40 PRINT AT 9, 2; "Each digit is 1 to 6."
  50 PRINT AT 11, 1; "Bull: right digit, right place"
  60 PRINT AT 12, 1; "Cow:  right digit, wrong place"
  70 PRINT AT 16, 4; "Press any key to start"
  80 PAUSE 0
  90 RANDOMIZE
 100 DIM c(4)
 110 FOR i = 1 TO 4: LET c(i) = INT (RND * 6) + 1: NEXT i
 120 CLS
 150 PRINT AT 0, 8; "*** LOCKSMITH ***"
 160 FOR t = 1 TO 10
 170 PRINT AT 20, 0; "Guess "; t; " of 10: ";
 180 INPUT g$
 190 IF LEN g$ <> 4 THEN GO TO 170
 200 DIM g(4)
 210 FOR i = 1 TO 4: LET g(i) = VAL g$(i): NEXT i
 300 LET bulls = 0
 310 FOR i = 1 TO 4
 320 IF g(i) = c(i) THEN LET bulls = bulls + 1
 330 NEXT i
 340 LET total = 0
 350 FOR d = 1 TO 6
 360 LET cc = 0: LET gc = 0
 370 FOR i = 1 TO 4
 380 IF c(i) = d THEN LET cc = cc + 1
 390 IF g(i) = d THEN LET gc = gc + 1
 400 NEXT i
 410 IF cc <= gc THEN LET total = total + cc
 420 IF gc < cc THEN LET total = total + gc
 430 NEXT d
 440 LET cows = total - bulls
 460 PRINT AT 2 + t, 2; g$; "  "; bulls; " bull  "; cows; " cow"
 500 IF bulls = 4 THEN GO TO 600
 510 NEXT t
 520 GO TO 660
 600 CLS
 610 PRINT AT 6, 8; "*** LOCKSMITH ***"
 620 PRINT AT 9, 6; "Code cracked!"
 630 PRINT AT 11, 6; "You got it in "; t; " guesses"
 640 BEEP 0.1, 10: BEEP 0.1, 15: BEEP 0.1, 20
 650 STOP
 660 CLS
 670 PRINT AT 6, 8; "*** LOCKSMITH ***"
 680 PRINT AT 9, 6; "Out of guesses!"
 690 PRINT AT 11, 6; "The code was ";
 700 FOR i = 1 TO 4: PRINT c(i);: NEXT i
 710 BEEP 0.3, -10
