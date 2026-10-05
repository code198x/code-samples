 120 IF k$="q" OR k$="Q" THEN GO TO 9000
 270 GO SUB 1900
 280 GO SUB 2000
 310 IF k$="q" OR k$="Q" THEN GO TO 9000
 330 IF k$="b" OR k$="B" THEN LET edit=1: GO SUB 6000: GO TO 280
 335 IF k$="s" OR k$="S" THEN LET edit=4: GO SUB 6000: GO TO 280
 340 IF k$="f" OR k$="F" THEN LET edit=2: GO SUB 6000: GO TO 280
 350 IF k$="p" OR k$="P" THEN LET edit=3: GO SUB 6000: GO TO 280
 510 IF k$="q" OR k$="Q" THEN GO TO 9000
1900 CLS : LET b$="                               "
1910 PRINT AT 0,1; INK 6; BRIGHT 1;"YEARFALL";AT 0,20;"YEAR ";yr
1920 PRINT AT 2,1; INK 5;"PEOPLE ";pop;AT 2,17;"LAND ";land
1930 PRINT AT 3,1; INK 5;"GRAIN  ";grain;AT 3,17;"PRICE ";price
1940 PRINT AT 5,1; INK 4;"PLAN";AT 5,17;"AMOUNT";AT 5,25;"COST"
1950 PRINT AT 6,1;"B  Buy land";AT 7,1;"S  Sell land"
1960 PRINT AT 8,1;"F  Feed grain";AT 9,1;"P  Plant acres"
1970 PRINT AT 12,1;"Food needed: ";3*pop
1980 RETURN
2138 PRINT AT 6,17;buy;"    "
2140 PRINT AT 7,17;sell;"    "
2150 PRINT AT 8,17;feed;"    ";AT 8,25;feed;"    "
2160 PRINT AT 9,17;plant;"    ";AT 9,25;plant;"    "
2162 LET t$="No land bought or sold."
2164 IF trade>0 THEN LET t$="Spend "+STR$ cost+" grain on land."
2166 IF trade<0 THEN LET t$="Receive "+STR$ (-cost)+" grain for land."
2168 PRINT AT 10,1; INK 6;t$;b$( TO 31-LEN t$)
2170 PRINT AT 11,1; INK 6;"Grain left: ";left;"    "
2190 PRINT AT 13,1;"Land after trade: ";acres;"    "
2200 PRINT AT 14,1;"Fed workers can plant: ";2*fed;"    "
2210 PRINT AT 16,1; INK 6;m$;b$( TO 31-LEN m$)
2220 LET t$="": IF ok=1 THEN LET t$="After harvest: "+STR$ (left+2*plant)+" to "+STR$ (left+5*plant)
2225 PRINT AT 17,1;t$;b$( TO 31-LEN t$)
2245 PRINT AT 21,1;b$
5150 IF k$="q" OR k$="Q" THEN GO TO 9000
7180 IF k$="q" OR k$="Q" THEN GO TO 9000
9000 CLS : PRINT AT 9,12; INK 6; BRIGHT 1;"YEARFALL"
9010 PRINT AT 11,6;"Thanks for playing.";AT 13,8;"RUN plays again."
9020 STOP
