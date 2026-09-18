10 BORDER 0: PAPER 0: INK 7: BRIGHT 0: CLS
200 LET w$="BOTTLE": LET g$="T"
250 LET d$="": LET found=0
260 FOR i=1 TO LEN w$: LET d$=d$+"_": NEXT i
400 FOR i=1 TO LEN w$
410 IF w$(i)=g$ THEN LET d$(i TO i)=g$: LET found=found+1
420 NEXT i
500 PRINT "Word: ";d$
510 PRINT "Matches: ";found
520 STOP
