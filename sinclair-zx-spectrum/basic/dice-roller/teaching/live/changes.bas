30 LET n=0: LET b=12: LET done=0: LET h$="####################": LET z$="                    "
430 GO SUB 1000
435 PRINT AT 19,1; "Rolling... Q stops this batch."
450 LET d=INT (RND*6)+1: LET t(d)=t(d)+1: LET n=n+1: LET done=done+1
460 GO SUB 1100
470 LET k$=INKEY$
480 IF k$="q" OR k$="Q" THEN GO TO 600
720 PRINT AT 19,1; "Samples vary; no fairness proof."
725 IF done<b THEN PRINT AT 19,1; "Stopped early. Counts kept.     "
1020 PRINT AT 2,1; "Bars 0-100%; rounded to 5%."
1050 PRINT AT row,2;j; AT row+1,5;CHR$ 91; AT row+1,26;CHR$ 93
1140 LET width=INT (20*t(j)/n+0.5)
1150 PRINT AT row+1,6; INK 5;h$(TO width);z$(TO 20-width)
1170 PRINT AT 20,1; "Batch ";done;" / ";b;"     "
