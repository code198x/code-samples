320 GO SUB 2000
330 IF hit = 1 THEN LET e$ = "That gap was not clear.": GO TO 4000
440 GO SUB 2000: LET steps = steps + 1
450 IF hit = 1 THEN LET e$ = "The lane caught you.": GO TO 4000
460 IF x = 7 AND y = 0 THEN LET e$ = "Across! A well-timed journey.": GO TO 4000
2000 LET hit = 0: IF ny <> 1 THEN RETURN
2015 LET delta = nx - p: LET delta = delta - 5 * INT (delta / 5)
2020 IF delta < 2 THEN LET hit = 1
2030 RETURN
3100 IF y = 1 THEN PRINT AT 2+2*y,1+2*x; PAPER 0; "  "; AT 3+2*y,1+2*x; "  ": RETURN
3110 PRINT AT 2+2*y,1+2*x; PAPER 1; INK 5; g$; AT 3+2*y,1+2*x; g$: RETURN
4000 PRINT AT 1,1; PAPER 0; INK 6; e$
4010 PRINT AT 20,2; PAPER 0; INK 7; "R plays again. Q quits.    "
4020 IF INKEY$ <> "" THEN GO TO 4020
4030 LET k$ = INKEY$
4040 IF k$ = "q" OR k$ = "Q" THEN GO TO 9000
4050 IF k$ = "r" OR k$ = "R" THEN GO TO 100
4060 GO TO 4030
