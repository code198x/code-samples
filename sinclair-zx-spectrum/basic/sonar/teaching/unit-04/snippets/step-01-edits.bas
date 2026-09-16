80 PRINT AT 21, 0; "N=1-2, M=3-4, F=5+ steps.";
171 IF d > 4 THEN LET d = 3: GO TO 180
172 IF d > 2 THEN LET d = 2: GO TO 180
173 IF d > 0 THEN LET d = 1
180 LET b$ = " F"
190 IF d = 2 THEN LET b$ = " M"
195 IF d = 1 THEN LET b$ = " N"
250 IF d = 3 THEN PRINT AT 21, 0; "Far: at least 5 steps away.";
251 IF d = 2 THEN PRINT AT 21, 0; "Medium: 3 or 4 steps away.";
252 IF d = 1 THEN PRINT AT 21, 0; "Near: 1 or 2 steps away.";
1010 PRINT AT 0, 6; "SONAR N1-2 M3-4 F5+"
