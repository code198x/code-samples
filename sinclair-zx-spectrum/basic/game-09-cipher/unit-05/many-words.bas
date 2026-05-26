  10 CLS
  20 RANDOMIZE
  30 DATA "SPECTRUM","COMPUTER","KEYBOARD","PROGRAM","SCREEN"
  40 DATA "PRINTER","CASSETTE","JOYSTICK","MEMORY","CIRCUIT"
  50 DATA "DISPLAY","LOADING","BORDER","COLOUR","PIXEL"
  60 DATA "BINARY","CURSOR","VOLUME","SYSTEM","BEEPER"
  70 LET total = 20
  80 LET pick = INT (RND * total) + 1
  90 RESTORE
 100 FOR i = 1 TO pick: READ w$: NEXT i
 110 LET d$ = ""
 120 FOR i = 1 TO LEN w$: LET d$ = d$ + "_": NEXT i
 130 LET lives = 7
 140 LET tried$ = ""
 150 CLS
 160 FOR i = 1 TO LEN d$: PRINT d$(i); " ";: NEXT i
 170 PRINT : PRINT
 180 PRINT "Lives: "; lives
 190 PRINT "Tried: "; tried$
 200 PRINT
 210 INPUT "Guess a letter: "; g$
 220 LET already = 0
 230 FOR i = 1 TO LEN tried$
 240 IF tried$(i) = g$ THEN LET already = 1
 250 NEXT i
 260 IF already = 1 THEN PRINT "Already tried!": PAUSE 50: GO TO 150
 270 LET tried$ = tried$ + g$
 280 LET found = 0
 290 FOR i = 1 TO LEN w$
 300 IF w$(i) = g$ THEN LET d$(i TO i) = g$: LET found = 1
 310 NEXT i
 320 IF found = 0 THEN LET lives = lives - 1: BEEP 0.1, -5
 330 IF found = 1 THEN BEEP 0.1, 10
 340 IF d$ = w$ THEN GO TO 500
 350 IF lives = 0 THEN GO TO 600
 360 GO TO 150
 500 CLS: PRINT "You got it! The word was "; w$
 510 BEEP 0.1, 10: BEEP 0.1, 15: BEEP 0.1, 20
 520 STOP
 600 CLS: PRINT "Out of lives! The word was "; w$
 610 BEEP 0.3, -10
 620 STOP
