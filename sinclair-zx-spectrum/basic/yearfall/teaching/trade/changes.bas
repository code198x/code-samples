210 LET price=6+INT (RND*5)
220 LET trade=0: LET feed=3*pop
330 IF k$="b" OR k$="B" THEN LET edit=1: GO SUB 6000: GO TO 270
335 IF k$="s" OR k$="S" THEN LET edit=4: GO SUB 6000: GO TO 270
410 LET land=land+trade: LET grain=left
550 LET yr=yr+1: GO TO 210
2020 LET acres=land+trade: LET cost=trade*price: LET left=grain-cost-feed-plant
2070 IF plant>acres THEN LET ok=0: LET m$="Planting exceeds your land."
2080 IF acres<0 THEN LET ok=0: LET m$="You cannot sell that much land."
2120 PRINT AT 3,1; INK 5; "GRAIN  ";grain; AT 3,17; "PRICE ";price
2135 LET buy=0: LET sell=0
2136 IF trade>0 THEN LET buy=trade
2137 IF trade<0 THEN LET sell=-trade
2138 PRINT AT 6,1; "B  Buy land"; AT 6,17;buy
2140 PRINT AT 7,1; "S  Sell land"; AT 7,17;sell
2162 IF trade=0 THEN PRINT AT 10,1; INK 6; "No land bought or sold."
2164 IF trade>0 THEN PRINT AT 10,1; INK 6; "Spend ";cost;" grain on land."
2166 IF trade<0 THEN PRINT AT 10,1; INK 6; "Receive ";-cost;" grain for land."
2190 PRINT AT 13,1; "Land after trade: ";acres
2220 IF ok=1 THEN PRINT AT 17,1; "After harvest: ";left+2*plant;" to ";left+5*plant
2230 PRINT AT 19,1; INK 5; "B/S land. F/P food/plant."
4050 IF cost>=0 THEN PRINT AT 7,1; "Land bought: spent"; AT 7,23;cost
4055 IF cost<0 THEN PRINT AT 7,1; "Land sold: received"; AT 7,23;-cost
6000 LET d$="": LET a$="Buy acres"
6005 IF edit=4 THEN LET a$="Sell acres"
6010 IF edit=2 THEN LET a$="Feed grain"
6210 IF edit=1 THEN LET trade=value
6215 IF edit=4 THEN LET trade=-value
