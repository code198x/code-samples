10 LET stage = 3
170 LET d = ABS (r - tr) + ABS (c - tc)
180 LET b$ = STR$ d
190 IF d < 10 THEN LET b$ = " " + b$
250 IF d <> 0 THEN PRINT AT 21, 0; "Distance "; d; ": rows + columns";
