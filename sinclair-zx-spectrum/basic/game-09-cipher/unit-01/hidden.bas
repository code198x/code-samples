  10 BORDER 0: PAPER 0: INK 7: CLS
  90 DATA "SPECTRUM"
 160 RESTORE
 170 READ w$
 180 LET d$ = ""
 190 FOR i = 1 TO LEN w$: LET d$ = d$ + "_": NEXT i
 220 CLS
 260 FOR i = 1 TO LEN d$: PRINT d$(i); " ";: NEXT i
 360 PRINT
 370 INPUT "Guess: "; g$
 450 FOR i = 1 TO LEN w$
 460 IF w$(i) = g$ THEN LET d$(i TO i) = g$
 470 NEXT i
 520 GO TO 220

9000 PRINT AT y, (32 - LEN a$) / 2; a$
9010 RETURN
