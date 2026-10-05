 330 IF nx<22 OR nx>233 OR ny<30 OR ny>145 THEN GO SUB 3100: LET e$="Hull lost. Try a gentler burn.": GO TO 4000
 350 GO SUB 3100
3000 LET px=INT (x+.5): LET py=INT (y+.5): LET ph=h
3010 PLOT INK 7; OVER 1;px+c(ph),py+d(ph)
3020 DRAW INK 7; OVER 1;e(ph)-c(ph),f(ph)-d(ph)
3030 DRAW INK 7; OVER 1;g(ph)-e(ph),j(ph)-f(ph)
3040 DRAW INK 7; OVER 1;c(ph)-g(ph),d(ph)-j(ph): RETURN
3100 IF INT (x+.5)<>px OR INT (y+.5)<>py OR h<>ph THEN GO SUB 3010: GO SUB 3000
3110 RETURN
