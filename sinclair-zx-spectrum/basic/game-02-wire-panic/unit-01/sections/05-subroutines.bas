2000 REM === Draw single digit d at px,py ===
2010 RESTORE 9000+d
2020 READ s$
2030 IF s$(1)="1" THEN FOR i=1 TO 6: PLOT px+9,py-i: DRAW 21,0: NEXT i
2040 IF s$(2)="1" THEN FOR i=1 TO 6: PLOT px+i,py-9: DRAW 0,-13: NEXT i
2050 IF s$(3)="1" THEN FOR i=1 TO 6: PLOT px+33+i,py-9: DRAW 0,-13: NEXT i
2060 IF s$(4)="1" THEN FOR i=1 TO 6: PLOT px+9,py-25-i: DRAW 21,0: NEXT i
2070 IF s$(5)="1" THEN FOR i=1 TO 6: PLOT px+i,py-33: DRAW 0,-13: NEXT i
2080 IF s$(6)="1" THEN FOR i=1 TO 6: PLOT px+33+i,py-33: DRAW 0,-13: NEXT i
2090 IF s$(7)="1" THEN FOR i=1 TO 6: PLOT px+9,py-49-i: DRAW 21,0: NEXT i
2100 RETURN
2400 REM === Draw number g centred in device ===
2410 FOR r=3 TO 9
2420 PRINT AT r,7; PAPER 0;"                  "
2430 NEXT r
2440 LET py=148
2450 IF g>=10 THEN GO TO 2480
2460 LET px=108: LET d=g: GO SUB 2000
2470 RETURN
2480 LET px=92: LET d=INT (g/10): GO SUB 2000
2490 LET px=140: LET d=g-INT (g/10)*10: GO SUB 2000
2500 RETURN
3000 REM === Centre text t$ on row r ===
3010 PRINT AT r,(32-LEN t$)/2;t$
3020 RETURN
3100 REM === Clear row r (cols 1-30) ===
3110 PRINT AT r,1;"                              "
3120 RETURN
