70 PRINT AT 8,2;"SPACE: thrust (with steering)"
210 LET keys=IN 57342: LET nx=x
220 IF INT (keys/2)-2*INT (keys/4)=0 THEN LET nx=nx-1
230 IF keys-2*INT (keys/2)=0 THEN LET nx=nx+1
260 LET burn=0: LET keys=IN 32766
270 IF keys-2*INT (keys/2)=0 AND fuel>0 THEN LET burn=1: LET fuel=fuel-1
