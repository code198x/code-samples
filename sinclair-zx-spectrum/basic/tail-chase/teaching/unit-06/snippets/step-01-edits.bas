130 GO SUB 1000: GO SUB 2000: GO SUB 2500
300 LET grow = (nr = fr AND nx = fc)
330 IF grow = 1 THEN GO TO 380
380 LET n = n + 1: LET eaten = eaten + 1
420 IF grow = 0 THEN GO TO 460
430 GO SUB 2500
440 IF eaten = 1 THEN LET e$ = "One snack. Nicely done!": GO TO 4000
450 GO SUB 2000
1020 PRINT AT 2,5; INK 7; "Eat one snack. R retries."
2000 LET fr = 8: LET fc = 12
2020 PRINT AT fr+3,fc+3; INK 6; CHR$ 150
2030 RETURN
2500 PRINT AT 1,4; INK 7; "FOOD "; eaten; "/1"; AT 1,18; "LENGTH "; n; " "
2510 RETURN
7000 RESTORE 7200: FOR j = 0 TO 55: READ v: POKE USR "a" + j,v: NEXT j: RETURN
7260 DATA 8,16,60,126,94,126,60,0
