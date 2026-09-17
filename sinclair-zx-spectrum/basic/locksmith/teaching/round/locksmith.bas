10 BORDER 0: PAPER 0: INK 7: BRIGHT 1: CLS
200 RANDOMIZE: DIM c(4)
210 FOR i = 1 TO 4: LET c(i) = INT (RND * 6) + 1: NEXT i
220 LET t = 1: LET g$ = "": GO SUB 1000
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
410 GO SUB 3000
420 GO SUB 4000
430 IF bulls = 4 THEN GO TO 5000
440 IF t = 10 THEN GO TO 5100
450 LET t = t + 1: LET g$ = ""
460 PRINT AT 18,2; "                            "
470 GO TO 230
1000 CLS
1010 PRINT AT 0,1; INK 5; "LOCKSMITH"; AT 0,21; INK 7; "10 TRIES"
1020 PRINT AT 2,1; INK 7; "Digits 1-6. Repeats allowed."
1030 PRINT AT 4,1; INK 5; "TRY"; AT 4,7; "CODE"; AT 4,19; "EXACT"; AT 4,26; "OTHER"
1040 FOR j = 5 TO 14: PRINT AT j,1; INK 1; "-"; AT j,7; ". . . ."; AT j,21; "."; AT j,28; ".": NEXT j
1050 PRINT AT 16,1; INK 5; "------------------------------"
1060 PRINT AT 20,1; INK 7; "1-6: digits   D: erase"
1070 PRINT AT 21,1; "ENTER: check  R: new  Q: quit"
1080 RETURN
2000 PRINT AT 17,1; INK 5; "TRY "; t; " "; AT 17,7; INK 7; "_ _ _ _"
2010 FOR i = 1 TO LEN g$: PRINT AT 17,5 + 2 * i; PAPER 1; INK 7; g$(i): NEXT i
2020 RETURN
3000 DIM g(4): LET bulls = 0: LET total = 0
3010 FOR i = 1 TO 4: LET g(i) = VAL g$(i): IF g(i) = c(i) THEN LET bulls = bulls + 1
3020 NEXT i
3030 FOR d = 1 TO 6
3040 LET cc = 0: LET gc = 0
3050 FOR i = 1 TO 4
3060 IF c(i) = d THEN LET cc = cc + 1
3070 IF g(i) = d THEN LET gc = gc + 1
3080 NEXT i
3090 IF cc <= gc THEN LET total = total + cc
3100 IF gc < cc THEN LET total = total + gc
3110 NEXT d
3120 LET cows = total - bulls: RETURN
4000 PRINT AT 4 + t,1; INK 7; t
4010 FOR i = 1 TO 4: PRINT AT 4 + t,5 + 2 * i; PAPER 1; INK 7; g$(i): NEXT i
4020 PRINT AT 4 + t,21; INK 4; bulls; AT 4 + t,28; INK 6; cows
4030 RETURN
5000 PRINT AT 17,1; INK 4; "OPEN! Attempts used: "; t; "      "
5010 GO TO 5200
5100 PRINT AT 17,1; INK 6; "LOCKED. Ten tries used.        "
5200 PRINT AT 18,1; "                              "; AT 18,1; INK 7; "The code: ";
5210 FOR i = 1 TO 4: PRINT c(i);: NEXT i
5220 PRINT AT 20,1; "R: new code   Q: quit          "
5230 PRINT AT 21,1; "                              "
5240 GO SUB 9000
5250 LET k$ = INKEY$: IF k$ = "" THEN GO TO 5250
5260 IF k$ = "r" OR k$ = "R" THEN GO TO 200
5270 IF k$ = "q" OR k$ = "Q" THEN GO TO 8000
5280 GO TO 5250
8000 PAPER 0: INK 7: BRIGHT 0: PRINT AT 21,1; "LOCKSMITH finished.           ": STOP
9000 IF INKEY$ <> "" THEN GO TO 9000
9010 RETURN
