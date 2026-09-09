310 LET ny=y+v: LET contact=0: LET side=0: LET limit=100*(h(nx+1)-1)
320 IF nx<>x AND y>=limit THEN LET contact=1: LET side=1: LET nx=x
345 IF side=1 THEN LET ny=y
710 LET m$="Terrain collision."
720 IF side=0 AND x>=20 AND x<=27 THEN LET m$="Too fast for the pad."
730 IF side=0 AND x>=20 AND x<=27 AND v<=12 AND v>=0 THEN LET m$="Safe landing!"
9000 DATA 20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,18,20,20,20,20,20,20,20,20,20,20,20,20
