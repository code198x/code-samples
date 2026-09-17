100 DIM g(16,24): DIM a(12): DIM b(12)
120 FOR j = 1 TO 4: LET a(j) = 8: LET b(j) = j + 5: LET g(8,j+5) = 1: NEXT j
310 IF g(nr,nx) = 1 AND (grow = 1 OR nr <> a(t) OR nx <> b(t)) THEN LET e$ = "You caught your tail!": GO TO 4000
340 LET g(a(t),b(t)) = 0: PRINT AT a(t)+3,b(t)+3; " "
400 LET a(h) = nr: LET b(h) = nx: LET g(nr,nx) = 1: LET steps = steps + 1
440 IF eaten = 1 THEN LET e$ = "One snack. Nicely done!": GO TO 4000
1020 PRINT AT 2,5; INK 7; "Eat one snack. R retries."
