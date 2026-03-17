 300 REM === Draw question card ===
 302 CLS
 304 FOR i=0 TO 31
 306 PRINT AT 0,i; PAPER 2;" "
 308 NEXT i
 310 PRINT AT 0,1; PAPER 2; INK 7;"Q";n;" of 8"
 312 PRINT AT 0,22; PAPER 2; INK 6;"Score: ";sc
 314 PRINT AT 4,4; INK 7;q$
 316 PRINT AT 8,6; INK 7;"A: ";a$
 318 PRINT AT 10,6; INK 7;"B: ";b$
 320 PRINT AT 12,6; INK 7;"C: ";c$
 322 PRINT AT 14,6; INK 7;"D: ";d$
 324 PRINT AT 18,4; INK 5;"Press A, B, C or D"
 326 RETURN
