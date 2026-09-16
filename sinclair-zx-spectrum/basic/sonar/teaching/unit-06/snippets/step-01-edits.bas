27 LET n = 0: LET lr = 0: LET lc = 0: LET pr = 0: LET pc = 0
120 LET seen = g(pr,pc)
130 LET d = seen
140 IF seen <> -1 THEN GO TO 200
160 LET g(pr,pc) = d: LET n = n + 1
250 GO SUB 2500
270 IF seen <> -1 THEN LET s$ = "Already probed. No extra count."
280 IF d = 0 THEN LET s$ = "Found in " + STR$ n + " distinct probes."
1180 GO SUB 2500
2500 PAPER 0: INK 7
2510 PRINT AT 1, 0; "Distinct probes: "; n; "   "
2520 RETURN
