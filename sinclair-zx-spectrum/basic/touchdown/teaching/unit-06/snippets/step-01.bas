60 PRINT AT 6,2;"O / P: steer left / right"
70 PRINT AT 8,2;"Use one control key at a time."
80 PRINT AT 10,2;"Pad: ========  Safe: 0 to 12"
130 LET x=18: LET y=400: LET v=0: LET fuel=45: LET r=4: LET burn=0
160 PRINT AT 1,1;"O/P STEER  SPACE THRUST  Q QUIT"
210 LET nx=x
220 IF k$="o" THEN LET nx=nx-1
230 IF k$="p" THEN LET nx=nx+1
240 IF nx<1 THEN LET nx=1
250 IF nx>30 THEN LET nx=30
380 PRINT AT r,x;" ";AT nr,nx;a$
390 LET x=nx: LET y=ny: LET r=nr
640 FOR c=20 TO 27: PRINT PAPER 6;INK 0;AT 20,c;"=": NEXT c
710 LET m$="Off the pad."
720 IF x>=20 AND x<=27 THEN LET m$="Too fast for the pad."
730 IF x>=20 AND x<=27 AND v<=12 AND v>=0 THEN LET m$="Safe landing!"
