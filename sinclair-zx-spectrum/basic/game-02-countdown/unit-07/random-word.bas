10 CLS
20 LET r = INT (RND * 5) + 1
30 IF r = 1 THEN LET w$ = "FIRE"
40 IF r = 2 THEN LET w$ = "JUMP"
50 IF r = 3 THEN LET w$ = "DUCK"
60 IF r = 4 THEN LET w$ = "RUN"
70 IF r = 5 THEN LET w$ = "STOP"
80 PRINT "Get ready..."
90 PAUSE 50 + INT (RND * 100)
100 PRINT w$
110 LET t = 0
120 IF INKEY$ <> "" THEN GO TO 150
130 LET t = t + 1
140 GO TO 120
150 PRINT "Your time: "; t
160 BEEP 0.1, 12
