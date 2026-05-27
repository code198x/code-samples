  10 BORDER 0: PAPER 0: INK 7: CLS
  12 DATA 60,126,255,255,255,255,126,60
  13 DATA 60,126,195,195,195,195,126,60
  14 FOR u = 0 TO 1: FOR j = 0 TO 7: READ b: POKE USR CHR$ (144 + u) + j, b: NEXT j: NEXT u
  20 PRINT AT 5, 8; BRIGHT 1; "*** LOCKSMITH ***"
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
 150 INVERSE 1: PRINT AT 0, 0; "      *** LOCKSMITH ***        ": INVERSE 0
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
 460 PRINT AT 2 + t, 2; g$; "  ";
 462 INK 2: FOR j = 1 TO bulls: PRINT CHR$ 144;: NEXT j
 464 INK 7: FOR j = 1 TO cows: PRINT CHR$ 145;: NEXT j
 466 INK 7
 480 INK 7
 490 BEEP 0.05, bulls * 5
 500 IF bulls = 4 THEN GO TO 600
 510 NEXT t
 520 GO TO 660
 600 CLS
 610 PRINT AT 6, 8; BRIGHT 1; "*** LOCKSMITH ***"
 620 PRINT AT 9, 6; INK 4; "Code cracked!"
 630 PRINT AT 11, 6; INK 7; "You got it in "; t; " guesses"
 640 BEEP 0.1, 10: BEEP 0.1, 15: BEEP 0.1, 20
 650 GO TO 720
 660 CLS
 670 PRINT AT 6, 8; BRIGHT 1; "*** LOCKSMITH ***"
 680 PRINT AT 9, 6; INK 2; "Out of guesses!"
 690 PRINT AT 11, 6; INK 7; "The code was ";
 700 FOR i = 1 TO 4: PRINT c(i);: NEXT i
 710 BEEP 0.3, -10
 720 PRINT AT 16, 4; "Press any key to play again"
 730 PAUSE 0
 740 GO TO 10

9000 PRINT AT y, (32 - LEN a$) / 2; a$
9010 RETURN
