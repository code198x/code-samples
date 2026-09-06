10 PAPER 0
20 INK 7
30 BORDER 0
40 CLS
50 PRINT "o left   p right"
55 LET row=10
56 LET col=15
60 PRINT AT row,col;"O"
70 LET k$=INKEY$
75 LET nextcol=col
80 IF k$="o" THEN LET nextcol=col-1
85 IF k$="p" THEN LET nextcol=col+1
90 IF nextcol<1 THEN GO TO 70
95 IF nextcol>30 THEN GO TO 70
100 IF nextcol=col THEN GO TO 70
110 PRINT AT row,col;" "
120 LET col=nextcol
130 PRINT AT row,col;"O"
140 PAUSE 5
150 GO TO 70
