10 BORDER 0: PAPER 0: INK 7: CLS
20 DIM b(8, 8)
30 GO SUB 400
40 GO SUB 500
50 GO SUB 600
60 STOP
400 REM === init board ===
410 FOR r = 1 TO 3
420 FOR c = 1 TO 8
430 IF (r + c) / 2 = INT ((r + c) / 2) THEN LET b(r, c) = 1
440 NEXT c
450 NEXT r
460 FOR r = 6 TO 8
470 FOR c = 1 TO 8
480 IF (r + c) / 2 = INT ((r + c) / 2) THEN LET b(r, c) = 2
490 NEXT c
495 NEXT r
498 RETURN
500 REM === draw board ===
510 FOR r = 1 TO 8
520 FOR c = 1 TO 8
530 IF (r + c) / 2 = INT ((r + c) / 2) THEN PRINT AT r + 2, c * 2 + 2; PAPER 0; " ": GO TO 550
540 PRINT AT r + 2, c * 2 + 2; PAPER 6; " "
550 NEXT c
560 NEXT r
570 RETURN
600 REM === draw pieces ===
610 FOR r = 1 TO 8
620 FOR c = 1 TO 8
630 IF b(r, c) = 0 THEN GO TO 660
640 IF b(r, c) = 1 THEN PRINT AT r + 2, c * 2 + 2; PAPER 0; INK 2; "o"
650 IF b(r, c) = 2 THEN PRINT AT r + 2, c * 2 + 2; PAPER 0; INK 4; "o"
660 NEXT c
670 NEXT r
680 RETURN
