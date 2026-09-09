70 PRINT AT 8,2;"Thrust uses fuel."
90 PRINT AT 12,2;"Empty tank? You still coast."
130 LET x=24: LET y=400: LET v=0: LET fuel=45: LET r=4: LET burn=0
150 PRINT AT 0,1;"FUEL       SPEED       MAX 12"
270 IF k$=" " AND fuel>0 THEN LET burn=1: LET fuel=fuel-1
370 PRINT AT 0,6;fuel;"  ";AT 0,19;v;"   "
