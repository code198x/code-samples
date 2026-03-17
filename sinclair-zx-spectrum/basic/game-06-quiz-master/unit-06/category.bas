 314 REM === Category label ===
 316 LET ci=6
 318 IF p=1 THEN LET m$="Science"
 320 IF p=2 THEN LET m$="History": LET ci=3
 322 IF p=3 THEN LET m$="Geography": LET ci=4
 324 IF p=4 THEN LET m$="Entertainment": LET ci=5
 326 PRINT AT 3,(32-LEN m$)/2; INK ci; BRIGHT 1;m$
