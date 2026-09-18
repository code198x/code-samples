300 GO SUB 8000
310 IF k$="q" OR k$="Q" THEN STOP
320 IF k$="r" OR k$="R" THEN GO TO 200
340 IF k$="f" OR k$="F" THEN LET edit=2: GO SUB 6000: GO TO 270
360 IF k$<>" " OR ok=0 THEN GO TO 300
500 GO SUB 8000
510 IF k$="q" OR k$="Q" THEN STOP
520 IF k$="r" OR k$="R" THEN GO TO 200
530 GO TO 500
2230 PRINT AT 19,1; INK 5; "F edits the food allocation."
2240 PRINT AT 20,1; "SPACE harvest. R reset. Q quit."
4140 PRINT AT 19,1; "R restarts. Q quits."
6000 LET d$="": LET a$="Feed grain"
6030 PRINT AT 19,0; "                                "; AT 20,0; "                                "; AT 21,0; "                               "
6040 PRINT AT 19,1; INK 6;a$;": ";d$;"_     "
6050 PRINT AT 20,1; "Digits, ENTER. DELETE erases."
6060 PRINT AT 21,1; "X cancels. Blank keeps plan."
6070 GO SUB 8000
6080 IF k$="x" OR k$="X" THEN RETURN
6090 IF CODE k$=13 AND d$="" THEN RETURN
6100 IF CODE k$=13 THEN GO TO 6200
6110 IF CODE k$=12 AND LEN d$>0 THEN LET d$=d$( TO LEN d$-1): GO TO 6040
6130 IF CODE k$<48 OR CODE k$>57 THEN GO TO 6070
6140 IF LEN d$>=4 THEN GO TO 6070
6170 LET d$=d$+k$: GO TO 6040
6200 LET value=VAL d$
6220 IF edit=2 THEN LET feed=value
6240 RETURN
8000 IF INKEY$<>"" THEN GO TO 8000
8010 LET k$=INKEY$
8020 IF k$="" THEN GO TO 8010
8030 RETURN
