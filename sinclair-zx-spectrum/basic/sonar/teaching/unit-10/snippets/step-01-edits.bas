 100 LET p$="Row": LET pl=0: GO SUB 3000: LET pr=v
 110 LET p$="Column": LET pl=1: GO SUB 3000: LET pc=v
3005 IF pl=0 THEN PRINT #1;AT 1,0;"                    ";
3010 PRINT #1;AT pl,0;p$;" (1-8, Q):   ";
3012 GO SUB 3200
3045 PRINT #1;AT pl,LEN p$+11;a$;
3200 LET a$=INKEY$: IF a$="" THEN GO TO 3200
3210 IF INKEY$<>"" THEN GO TO 3210
3220 RETURN
5030 PRINT AT 7,1;"Press a row key, then a column."
5085 IF INKEY$<>"" THEN GO TO 5085
5090 PRINT #1;AT 0,0;"Any key to search, Q quits.";
5100 GO SUB 3200
5110 IF a$="q" OR a$="Q" THEN GO TO 9000
6000 PRINT #1;AT 0,0;"R another round, Q quits:   ";AT 1,0;"                    ";
6010 GO SUB 3200
6040 LET s$="Press R for another round or Q.": GO SUB 2600
