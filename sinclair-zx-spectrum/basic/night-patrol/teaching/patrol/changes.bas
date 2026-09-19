100 LET x=3: LET y=16
120 LET gx=7: LET gy=5: LET gd=1
130 LET got=0: LET outcome=0: LET beat=0: LET steps=0
140 GO SUB 1000: GO SUB 3300: GO SUB 2500
150 LET tick=PEEK 23672
230 LET elapsed=PEEK 23672-tick: IF elapsed<0 THEN LET elapsed=elapsed+256
240 IF elapsed<8 THEN GO TO 200
370 IF x=gx AND y=gy THEN LET outcome=1: GO TO 4000
400 LET beat=beat+1: IF beat<2 THEN GO TO 470
410 LET beat=0: LET r=gy: LET c=gx
430 IF (gd=1 AND gx=24) OR (gd=2 AND gy=14) OR (gd=3 AND gx=7) OR (gd=4 AND gy=5) THEN LET gd=gd+1: IF gd=5 THEN LET gd=1
440 LET gx=gx+a(gd): LET gy=gy+b(gd): GO SUB 2000
455 GO SUB 3300
460 IF x=gx AND y=gy THEN LET outcome=1: GO TO 4000
470 LET tick=PEEK 23672: GO TO 200
2050 IF r=gy AND c=gx THEN LET z$=g$(gd): LET colour=6
3300 LET r=gy: LET c=gx: GO SUB 2000: RETURN
4010 IF outcome=1 THEN PRINT AT 1,1; INK 2; BRIGHT 1; "CAUGHT! Keep clear of the guard."
7000 RESTORE 7500: FOR j=0 TO 31: READ a: POKE USR "a"+j,a: NEXT j
7010 DIM a(4): DIM b(4): LET a(1)=1: LET b(2)=1: LET a(3)=-1: LET b(4)=-1
7020 LET g$=">v<"+CHR$ 94: RETURN
