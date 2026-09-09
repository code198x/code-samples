20 DIM h(32)
30 FOR c=1 TO 32: LET h(c)=20: NEXT c
310 LET ny=y+v: LET contact=0: LET limit=100*(h(nx+1)-1)
610 FOR j=h(c+1) TO 21: PRINT PAPER 4;INK 0;AT j,c;" ";: NEXT j
620 PRINT PAPER 4;INK 0;AT h(c+1),c;"#"
