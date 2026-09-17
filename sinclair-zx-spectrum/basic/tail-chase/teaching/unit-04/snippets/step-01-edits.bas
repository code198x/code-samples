100 DIM a(4): DIM b(4)
110 LET n = 4: LET eaten = 0: LET h = 4: LET t = 1: LET dr = 0: LET dc = 1: LET steps = 0
120 FOR j = 1 TO 4: LET a(j) = 8: LET b(j) = j + 5: NEXT j
170 IF k$ = "r" OR k$ = "R" THEN GO TO 100
280 LET nr = a(h) + dr: LET nx = b(h) + dc
300 LET grow = 0
310 GO SUB 3500: IF hit = 1 THEN LET e$ = "You caught your tail!": GO TO 4000
320 PRINT AT a(h)+3,b(h)+3; INK 5; CHR$ 149
340 PRINT AT a(t)+3,b(t)+3; " "
390 FOR j = 1 TO 3: LET a(j) = a(j+1): LET b(j) = b(j+1): NEXT j
400 LET a(h) = nr: LET b(h) = nx: LET steps = steps + 1
1050 FOR j = 1 TO 4: PRINT AT a(j)+3,b(j)+3; INK 5; CHR$ 149: NEXT j
3040 PRINT AT a(h)+3,b(h)+3; INK 7; CHR$ z
3500 LET hit = 0
3510 FOR j = 2 TO n
3530 IF a(j) = nr AND b(j) = nx THEN LET hit = 1
3550 NEXT j: RETURN
4050 IF k$ = "r" OR k$ = "R" THEN GO TO 100
7000 RESTORE 7200: FOR j = 0 TO 47: READ v: POKE USR "a" + j,v: NEXT j: RETURN
7250 DATA 0,60,126,126,126,126,60,0
