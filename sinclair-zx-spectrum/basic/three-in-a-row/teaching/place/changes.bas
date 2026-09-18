40 GO TO 250
250 GO SUB 9000
260 LET k$ = INKEY$: IF k$ = "" THEN GO TO 260
270 IF k$ = "q" OR k$ = "Q" THEN GO TO 8000
280 IF k$ = "r" OR k$ = "R" THEN RUN
290 IF k$ < "1" OR k$ > "9" THEN GO TO 250
300 LET n = VAL k$
310 IF b(n) <> 0 THEN PRINT AT 18,2; INK 6; "Taken. Choose an empty square.": GO TO 250
320 LET b(n) = 1: GO SUB 2000
330 GO TO 250
1060 PRINT AT 18,2; INK 7; "Choose a square with 1-9."
1090 PRINT AT 21,2; INK 7; "1-9: place  R: reset  Q: quit"
2050 INK 5: FOR z = 0 TO 1: PLOT x - 10 + z,y - 10: DRAW 20,20: PLOT x - 10 + z,y + 10: DRAW 20,-20: NEXT z
2060 RETURN
8000 PAPER 0: INK 7: BRIGHT 0: PRINT AT 21,2; "Three in a Row finished.     ": STOP
9000 IF INKEY$ <> "" THEN GO TO 9000
9010 RETURN
