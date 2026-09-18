10 BORDER 0: PAPER 0: INK 7: BRIGHT 1: CLS
20 DIM b(9): LET moves = 0
30 GO SUB 1000
40 GO TO 250
250 GO SUB 9000
260 LET k$ = INKEY$: IF k$ = "" THEN GO TO 260
270 IF k$ = "q" OR k$ = "Q" THEN GO TO 8000
280 IF k$ = "r" OR k$ = "R" THEN RUN
290 IF k$ < "1" OR k$ > "9" THEN GO TO 250
300 LET n = VAL k$
310 IF b(n) <> 0 THEN PRINT AT 18,2; INK 6; "Taken. Choose an empty square.": GO TO 250
320 LET b(n) = 1: LET moves = moves + 1: GO SUB 2000
330 GO SUB 3000
340 IF winner > 0 OR moves = 9 THEN GO TO 4900
600 PRINT AT 18,2; INK 6; "O is choosing...             "
610 GO SUB 4000
620 LET n = mv: LET b(n) = 2: LET moves = moves + 1: GO SUB 2000
630 PRINT AT 19,2; INK 5; "O chose "; mv; ": "; a$; "        "
640 GO SUB 3000
650 IF winner > 0 OR moves = 9 THEN GO TO 4900
660 PRINT AT 18,2; INK 7; "Your move: choose 1-9.        "
670 GO TO 250
1000 CLS
1010 PRINT AT 0,8; INK 5; "THREE IN A ROW"
1030 INK 1: FOR i = 0 TO 3: PLOT 56 + i * 48,32: DRAW 0,120: NEXT i
1040 FOR i = 0 TO 3: PLOT 56,32 + i * 40: DRAW 144,0: NEXT i
1050 FOR n = 1 TO 9: GO SUB 2000: NEXT n
1060 PRINT AT 18,2; INK 7; "Your move: choose 1-9."
1090 PRINT AT 21,2; INK 7; "1-9: place  R: reset  Q: quit"
1100 RETURN
2000 LET row = INT ((n - 1) / 3): LET col = n - 1 - row * 3
2010 LET x = 80 + col * 48: LET y = 132 - row * 40
2020 PRINT AT 5 + row * 5,10 + col * 6; INK 7; " "
2030 IF b(n) = 0 THEN PRINT AT 5 + row * 5,10 + col * 6; INK 7; n: RETURN
2040 IF b(n) = 2 THEN GO TO 2100
2050 INK 5: FOR z = 0 TO 1: PLOT x - 10 + z,y - 10: DRAW 20,20: PLOT x - 10 + z,y + 10: DRAW 20,-20: NEXT z
2060 RETURN
2100 INK 7: FOR z = 0 TO 1: PLOT x - 6,y + 10 - z: DRAW 12,0: DRAW 4,-4: DRAW 0,-12: DRAW -4,-4: DRAW -12,0: DRAW -4,4: DRAW 0,12: DRAW 4,4: NEXT z
2110 RETURN
3000 LET winner = 0: LET wl = 0: RESTORE 9500
3010 FOR w = 1 TO 8: READ p,q,f
3020 IF b(p) <> 0 AND b(p) = b(q) AND b(q) = b(f) THEN LET winner = b(p): LET wl = w
3030 NEXT w: RETURN
4000 LET mark = 2: GO SUB 4500
4010 IF mv > 0 THEN LET a$ = "win": RETURN
4020 LET mark = 1: GO SUB 4500
4030 IF mv > 0 THEN LET a$ = "block": RETURN
4040 IF b(5) = 0 THEN LET mv = 5: LET a$ = "centre": RETURN
4050 RESTORE 9530
4060 FOR j = 1 TO 4: READ v
4070 IF mv = 0 AND b(v) = 0 THEN LET mv = v
4080 NEXT j
4090 IF mv > 0 THEN LET a$ = "corner": RETURN
4100 FOR j = 1 TO 9: IF b(j) = 0 THEN LET mv = j
4110 NEXT j: LET a$ = "edge": RETURN
4500 LET mv = 0: RESTORE 9500
4510 FOR w = 1 TO 8: READ p,q,f
4520 IF mv = 0 AND b(p) = mark AND b(q) = mark AND b(f) = 0 THEN LET mv = f
4530 IF mv = 0 AND b(p) = mark AND b(f) = mark AND b(q) = 0 THEN LET mv = q
4540 IF mv = 0 AND b(q) = mark AND b(f) = mark AND b(p) = 0 THEN LET mv = p
4550 NEXT w: RETURN
4900 LET r$ = "DRAW. No line completed."
4910 IF winner = 1 THEN LET r$ = "X WINS. Three in a row."
4920 IF winner = 2 THEN LET r$ = "O WINS. Three in a row."
4930 IF wl > 0 THEN GO SUB 6000
4940 PRINT AT 18,2; INK 6; r$; "      "
5000 GO SUB 9000
5010 LET k$ = INKEY$: IF k$ = "" THEN GO TO 5010
5020 IF k$ = "q" OR k$ = "Q" THEN GO TO 8000
5030 IF k$ = "r" OR k$ = "R" THEN RUN
5040 GO TO 5010
6000 RESTORE 9500: FOR w = 1 TO wl: READ p,q,f: NEXT w
6010 LET row = INT ((p - 1) / 3): LET col = p - 1 - row * 3
6020 LET sx = 80 + col * 48: LET sy = 132 - row * 40
6030 LET row = INT ((f - 1) / 3): LET col = f - 1 - row * 3
6040 INK 6: PLOT sx,sy: DRAW 80 + col * 48 - sx,132 - row * 40 - sy: RETURN
8000 PAPER 0: INK 7: BRIGHT 0: PRINT AT 21,2; "Three in a Row finished.     ": STOP
9000 IF INKEY$ <> "" THEN GO TO 9000
9010 RETURN
9500 DATA 1,2,3,4,5,6,7,8,9
9510 DATA 1,4,7,2,5,8,3,6,9
9520 DATA 1,5,9,3,5,7
9530 DATA 1,3,7,9
