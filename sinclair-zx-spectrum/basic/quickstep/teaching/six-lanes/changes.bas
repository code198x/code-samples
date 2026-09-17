100 DIM p(6): DIM d(6): DIM t(6): DIM v(6): DIM r(6): DIM a$(6,30): DIM b$(6,30)
110 LET x = 7: LET y = 8: LET steps = 0: RESTORE 7100
120 FOR i = 1 TO 6: READ p(i),d(i),v(i),r(i): LET t(i) = v(i): NEXT i
140 FOR i = 1 TO 6: FOR j = 0 TO 2: FOR k = 0 TO 3
150 LET c = 2 * p(i) + 10 * j + k: LET c = c - 30 * INT (c / 30) + 1
160 LET a$(i,c) = CHR$ (144 + k): LET b$(i,c) = CHR$ (148 + k)
170 NEXT k: NEXT j: NEXT i
310 IF nx < 0 OR nx > 14 OR ny < 0 OR ny > 8 THEN LET nx = x: LET ny = y
350 FOR i = 1 TO 6: LET t(i) = t(i) - 1
360 IF t(i) > 0 THEN GO TO 430
370 LET t(i) = v(i): LET p(i) = p(i) + d(i)
380 IF p(i) = 15 THEN LET p(i) = 0
390 IF p(i) = -1 THEN LET p(i) = 14
400 IF d(i) = 1 THEN LET a$(i) = a$(i,29 TO 30) + a$(i,1 TO 28): LET b$(i) = b$(i,29 TO 30) + b$(i,1 TO 28)
410 IF d(i) = -1 THEN LET a$(i) = a$(i,3 TO 30) + a$(i,1 TO 2): LET b$(i) = b$(i,3 TO 30) + b$(i,1 TO 2)
420 GO SUB 1200: IF y = r(i) THEN GO SUB 3000
430 NEXT i
1030 FOR j = 0 TO 8 STEP 4
1080 FOR i = 1 TO 6: GO SUB 1200: LET z$ = ">": IF d(i) = -1 THEN LET z$ = "<"
1082 NEXT i
1200 LET row = 2 + 2 * r(i): LET ink = 6: IF d(i) = -1 THEN LET ink = 5
1210 PRINT AT row,1; PAPER 0; INK ink; a$(i); AT row+1,1; b$(i)
2000 LET hit = 0: IF ny = 0 OR ny = 4 OR ny = 8 THEN RETURN
2010 LET lane = ny: IF ny > 4 THEN LET lane = ny - 1
2015 LET delta = nx - p(lane): LET delta = delta - 5 * INT (delta / 5)
3000 LET paper = 0: IF y = 0 OR y = 4 OR y = 8 THEN LET paper = 1
3100 IF y <> 0 AND y <> 4 AND y <> 8 THEN PRINT AT 2+2*y,1+2*x; PAPER 0; "  "; AT 3+2*y,1+2*x; "  ": RETURN
7100 DATA 0,1,3,1,9,-1,4,2,11,1,2,3
7110 DATA 7,-1,3,5,1,1,4,6,10,-1,2,7
