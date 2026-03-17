  10 DIM s(4)
  20 LET s(1)=3
  30 LET s(2)=1
  40 LET s(3)=2
  50 LET s(4)=0
  60 FOR i=1 TO 4
  70 PRINT "Category ";i;": ";s(i)
  80 NEXT i
  90 PRINT
 100 LET t=s(1)+s(2)+s(3)+s(4)
 110 PRINT "Total: ";t
