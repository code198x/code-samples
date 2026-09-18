10 BORDER 0: PAPER 0: INK 7: BRIGHT 0: CLS
200 LET w$="BOTTLE"
250 LET d$=""
260 FOR i=1 TO LEN w$: LET d$=d$+"_": NEXT i
270 LET a$="Choose a letter."
300 CLS: PRINT AT 3,2; "CIPHER"; AT 6,2;d$; AT 10,2;a$; AT 14,2;"Letter guesses. ENTER quits."
310 GO SUB 8000
320 IF CODE k$=13 THEN STOP
330 LET c=CODE k$
340 IF c<97 OR c>122 THEN GO TO 310
350 LET g$=CHR$ (c-32): LET found=0
400 FOR i=1 TO LEN w$
410 IF w$(i)=g$ THEN LET d$(i TO i)=g$: LET found=found+1
420 NEXT i
430 IF found>0 THEN LET a$=g$+" reveals "+STR$ found+" letter(s)."
440 IF found=0 THEN LET a$=g$+" is not in the word."
470 GO TO 300
8000 LET k$=INKEY$
8010 IF INKEY$<>"" THEN GO TO 8010
8020 LET k$=INKEY$: IF k$="" THEN GO TO 8020
8030 IF CODE k$>=65 AND CODE k$<=90 THEN LET k$=CHR$ (CODE k$+32)
8040 RETURN
