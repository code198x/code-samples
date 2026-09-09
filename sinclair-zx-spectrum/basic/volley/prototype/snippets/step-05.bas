26 LET missed=0
200 LET nx=x+dx: LET ny=y+dy
210 IF ny=2 THEN LET dy=1: LET ny=4
220 IF ny=20 THEN LET dy=-1: LET ny=18
230 IF nx=30 THEN LET dx=-1: LET nx=28
240 IF nx=2 THEN GO SUB 600
245 IF missed=1 THEN GO TO 700
250 LET x=nx: LET y=ny
600 IF ny<p THEN LET missed=1: RETURN
610 IF ny>p+2 THEN LET missed=1: RETURN
620 LET dx=1: LET nx=4
630 RETURN
700 PRINT AT 21,1;"Miss. RUN to try again.": STOP
