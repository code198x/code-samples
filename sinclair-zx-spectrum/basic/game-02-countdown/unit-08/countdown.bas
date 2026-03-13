10 REM Countdown
20 CLS
30 PRINT "== Countdown =="
40 PRINT
50 PRINT "React to the word!"
60 PRINT "5 rounds. Be fast."
70 PAUSE 100
80 LET b = 9999
90 LET n = 1
100 CLS
110 PRINT "Round "; n; " of 5"
120 PRINT
130 PRINT "Get ready..."
140 PAUSE 50 + INT (RND * 100)
150 LET r = INT (RND * 5) + 1
160 IF r = 1 THEN LET w$ = "FIRE"
170 IF r = 2 THEN LET w$ = "JUMP"
180 IF r = 3 THEN LET w$ = "DUCK"
190 IF r = 4 THEN LET w$ = "RUN"
200 IF r = 5 THEN LET w$ = "STOP"
210 PRINT w$
220 BEEP 0.05, 12
230 LET t = 0
240 IF INKEY$ <> "" THEN GO TO 270
250 LET t = t + 1
260 GO TO 240
270 BEEP 0.1, 0
280 PRINT "Time: "; t
290 IF t < b THEN PRINT "New best!"
300 IF t < b THEN LET b = t
310 PAUSE 50
320 LET n = n + 1
330 IF n < 6 THEN GO TO 100
340 CLS
350 PRINT "== Results =="
360 PRINT
370 PRINT "Best time: "; b
380 PRINT
390 PRINT "Well done!"
