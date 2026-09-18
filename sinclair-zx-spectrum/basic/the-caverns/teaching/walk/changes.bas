250 LET rm = 1: LET turns = 0
260 LET d$ = "NSEW": LET e$ = "nsew": LET h$ = "Choose a tunnel to explore."
300 GO SUB 9000
310 LET k$ = INKEY$: IF k$ = "" THEN GO TO 310
320 IF k$ = "q" OR k$ = "Q" THEN GO TO 8000
330 IF k$ = "r" OR k$ = "R" THEN GO TO 200
340 LET dir = 0: FOR j = 1 TO 4: IF k$ = d$(j) OR k$ = e$(j) THEN LET dir = j
350 NEXT j
360 IF dir = 0 AND k$ <> " " THEN GO TO 300
370 LET dest = rm
380 IF dir > 0 THEN LET dest = m(rm,dir)
390 IF dest = 0 THEN PRINT AT 18,2; INK 6; "No tunnel in that direction. ": GO TO 300
400 LET turns = turns + 1: LET h$ = "Your footsteps fade away."
430 LET rm = dest
490 GO TO 270
1020 PRINT AT 2,2; INK 6; "TURNS "; turns
1190 PRINT AT 18,2; INK 5; h$
1200 PRINT AT 20,2; INK 7; "N S E W / SPACE waits"
1210 PRINT AT 21,2; INK 7; "R: restart   Q: quit"
8000 PRINT AT 21,2; INK 7; "The Caverns finished.       ": STOP
9000 IF INKEY$ <> "" THEN GO TO 9000
9010 RETURN
