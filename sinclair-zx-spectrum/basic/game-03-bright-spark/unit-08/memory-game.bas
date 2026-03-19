  10 REM Memory Game — text version
  20 RANDOMIZE
  30 CLS
  40 LET s$=""
  50 LET score=0
  60 REM === Add to sequence ===
  70 LET p=INT (RND*4)+1
  80 LET p$="1"
  90 IF p=2 THEN LET p$="2"
 100 IF p=3 THEN LET p$="3"
 110 IF p=4 THEN LET p$="4"
 120 LET s$=s$+p$
 130 REM === Show sequence ===
 140 PRINT "Round "; LEN s$; ":"
 150 FOR i=1 TO LEN s$
 160 PRINT s$(i); " ";
 170 BEEP 0.2,VAL s$(i)*4
 180 PAUSE 10
 190 NEXT i
 200 PRINT
 210 REM === Player repeats ===
 220 PRINT "Your turn: ";
 230 FOR i=1 TO LEN s$
 240 LET k$=INKEY$
 250 IF k$="" THEN GO TO 240
 260 PRINT k$; " ";
 270 IF k$<>s$(i) THEN PRINT : PRINT "Wrong! Score: "; score: STOP
 280 BEEP 0.1,VAL k$*4
 290 PAUSE 10
 300 IF INKEY$<>"" THEN GO TO 300
 310 NEXT i
 320 LET score=score+1
 330 PRINT : PRINT "Correct!"
 340 PAUSE 25
 350 GO TO 60
