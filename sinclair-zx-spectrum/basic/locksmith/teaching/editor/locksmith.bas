10 BORDER 0: PAPER 0: INK 7: BRIGHT 1: CLS
200 LET t = 1
220 LET g$ = "": GO SUB 1000
230 GO SUB 9000
240 GO SUB 2000
250 LET k$ = INKEY$: IF k$ = "" THEN GO TO 250
260 IF k$ = "q" OR k$ = "Q" THEN GO TO 8000
270 IF k$ = "r" OR k$ = "R" THEN GO TO 200
280 IF k$ = CHR$ 13 THEN GO TO 400
290 IF k$ = "d" OR k$ = "D" OR k$ = CHR$ 12 THEN GO TO 350
300 IF k$ < "1" OR k$ > "6" THEN GO TO 230
310 IF LEN g$ = 4 THEN GO TO 230
320 LET g$ = g$ + k$: GO TO 230
350 IF LEN g$ > 0 THEN LET g$ = g$( TO LEN g$ - 1)
360 GO TO 230
400 IF LEN g$ <> 4 THEN PRINT AT 18,2; INK 6; "Enter four digits first.     ": GO TO 230
410 PRINT AT 18,2; INK 4; "Four digits ready.          ": GO TO 230
1000 CLS
1010 PRINT AT 0,1; INK 5; "LOCKSMITH"; AT 0,21; INK 7; "PRACTICE"
1020 PRINT AT 2,1; INK 7; "Build a four-digit guess."
1050 PRINT AT 16,1; INK 5; "------------------------------"
1060 PRINT AT 20,1; INK 7; "1-6: digits   D: erase"
1070 PRINT AT 21,1; "ENTER: check  R: clear Q: quit"
1080 RETURN
2000 PRINT AT 17,1; INK 5; "TRY "; t; " "; AT 17,7; INK 7; "_ _ _ _"
2010 FOR i = 1 TO LEN g$: PRINT AT 17,5 + 2 * i; PAPER 1; INK 7; g$(i): NEXT i
2020 RETURN
8000 PAPER 0: INK 7: BRIGHT 0: PRINT AT 21,1; "LOCKSMITH finished.           ": STOP
9000 IF INKEY$ <> "" THEN GO TO 9000
9010 RETURN
