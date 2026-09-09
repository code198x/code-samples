10 BORDER 0: PAPER 0: INK 7: BRIGHT 1: CLS
20 DIM h(32): RESTORE 9000
30 FOR c=1 TO 32: READ h(c): NEXT c
40 FOR c=0 TO 15: READ b: POKE USR "a"+c,b: NEXT c
50 PRINT AT 3,9;"TOUCHDOWN"
60 PRINT AT 6,2;"O / P: steer left / right"
70 PRINT AT 8,2;"SPACE: thrust (with steering)"
80 PRINT AT 10,2;"Pad: ====  Safe speed: 0 to 12"
90 PRINT AT 12,2;"Empty tank? You still coast."
100 PRINT AT 15,2;"S launches. Q quits."
110 GO SUB 800: IF k$="q" THEN GO TO 850
120 CLS: GO SUB 600
130 LET x=6: LET y=400: LET v=0: LET fuel=45: LET r=4: LET burn=0
140 PRINT AT r,x;CHR$ 144
150 PRINT AT 0,1;"FUEL       SPEED       MAX 12"
160 PRINT AT 1,1;"O/P STEER  SPACE THRUST  Q QUIT"
200 LET k$=INKEY$: IF k$="q" THEN GO TO 850
210 LET keys=IN 57342: LET nx=x
220 IF INT (keys/2)-2*INT (keys/4)=0 THEN LET nx=nx-1
230 IF keys-2*INT (keys/2)=0 THEN LET nx=nx+1
240 IF nx<1 THEN LET nx=1
250 IF nx>30 THEN LET nx=30
260 LET burn=0: LET keys=IN 32766
270 IF keys-2*INT (keys/2)=0 AND fuel>0 THEN LET burn=1: LET fuel=fuel-1
280 LET v=v+2-6*burn
290 IF v>60 THEN LET v=60
300 IF v<-30 THEN LET v=-30
310 LET ny=y+v: LET contact=0: LET side=0: LET limit=100*(h(nx+1)-1)
320 IF nx<>x AND y>=limit THEN LET contact=1: LET side=1: LET nx=x
330 IF ny>=limit THEN LET contact=1
340 IF contact=1 THEN LET ny=limit
345 IF side=1 THEN LET ny=y
350 IF ny<300 THEN LET ny=300: LET v=0
360 LET nr=INT (ny/100)
370 PRINT AT 0,6;fuel;"  ";AT 0,19;v;"   "
380 PRINT AT r,x;" ";AT nr,nx;CHR$ (144+burn)
390 LET x=nx: LET y=ny: LET r=nr
400 IF contact=1 THEN GO TO 700
410 PAUSE 2: GO TO 200
600 FOR c=0 TO 31
610 FOR j=h(c+1) TO 21: PRINT PAPER 4;INK 0;AT j,c;" ";: NEXT j
620 PRINT PAPER 4;INK 0;AT h(c+1),c;"#"
630 NEXT c
640 FOR c=23 TO 26: PRINT PAPER 6;INK 0;AT 20,c;"=": NEXT c
650 RETURN
700 PRINT AT r,x;CHR$ 144
710 LET m$="Terrain collision."
720 IF side=0 AND x>=23 AND x<=26 THEN LET m$="Too fast for the pad."
730 IF side=0 AND x>=23 AND x<=26 AND v<=12 AND v>=0 THEN LET m$="Safe landing!"
740 PRINT AT 2,1;m$;"    "
750 IF m$="Safe landing!" THEN BEEP .08,12: BEEP .12,19
760 IF m$<>"Safe landing!" THEN BEEP .15,-12
770 PRINT AT 1,1;"R retries. Q quits.            "
780 IF INKEY$<>"" THEN GO TO 780
790 LET k$=INKEY$: IF k$<>"r" AND k$<>"q" THEN GO TO 790
795 IF INKEY$<>"" THEN GO TO 795
796 IF k$="q" THEN GO TO 850
797 GO TO 120
800 IF INKEY$<>"" THEN GO TO 800
810 LET k$=INKEY$: IF k$<>"s" AND k$<>"q" THEN GO TO 810
820 IF INKEY$<>"" THEN GO TO 820
830 RETURN
850 IF INKEY$<>"" THEN GO TO 850
860 PAPER 0: INK 7: CLS: PRINT "Finished.": STOP
9000 DATA 18,18,18,19,19,19,19,19,18,17,16,15,14,14,14,15,16,17,18,19,20,20,20,20,20,20,20,20,19,18,18,18
9010 DATA 24,60,60,126,90,66,0,0,24,60,60,126,90,66,24,36
