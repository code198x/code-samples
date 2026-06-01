  10 BORDER 0: PAPER 0: INK 7: CLS
 120 DATA "SPECTRUM"
 190 RESTORE
 200 READ w$
 210 LET d$ = ""
 220 FOR i = 1 TO LEN w$: LET d$ = d$ + "_": NEXT i
 250 CLS
 290 FOR i = 1 TO LEN d$: PRINT d$(i); " ";: NEXT i
 390 PRINT
 400 INPUT "Guess: "; g$: IF g$ >= "a" AND g$ <= "z" THEN LET g$ = CHR$ (CODE g$ - 32)
 480 FOR i = 1 TO LEN w$
 490 IF w$(i) = g$ THEN LET d$(i TO i) = g$
 500 NEXT i
 550 GO TO 250
