10 PAPER 0
20 INK 7
30 BORDER 0
40 CLS
50 PRINT "o left   p right"
51 PRINT "One press, one step. q quits."
55 LET row=10
56 LET col=15
59 IF INKEY$<>"" THEN GO TO 59
60 PRINT AT row,col;"O"
70 LET k$=INKEY$
71 IF k$="" THEN GO TO 70
72 IF k$="q" THEN GO TO 200
75 LET nextcol=col
80 IF k$="o" THEN LET nextcol=col-1
85 IF k$="p" THEN LET nextcol=col+1
90 IF nextcol<1 THEN GO TO 160
95 IF nextcol>30 THEN GO TO 160
100 IF nextcol=col THEN GO TO 160
110 PRINT AT row,col;" "
120 LET col=nextcol
130 PRINT AT row,col;"O"
160 IF INKEY$<>"" THEN GO TO 160
170 GO TO 70
200 PRINT AT 20,0;"Finished. RUN to try again."
210 STOP
