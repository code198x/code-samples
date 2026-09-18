1030 PRINT AT 4,1; INK 5; "FACE  COUNT   NOW%"
1080 NEXT j: PRINT AT 18,1; "Fair model: about 16.7% each."
1120 LET row=5+2*(j-1): LET pc=INT (1000*t(j)/n+0.5)/10
1130 PRINT AT row,7;t(j);"    "; AT row,15;pc;"   "
