10 BORDER 0: PAPER 0: INK 7: CLS
20 DIM b(8, 8)
30 GO SUB 400
40 GO SUB 500
50 GO SUB 600
60 GO SUB 700
70 LET t = 1
80 REM game loop
90 GO SUB 800
100 GO SUB 850
110 PRINT AT 15, 1; "From: "; CHR$ (64 + p); q
120 PRINT AT 16, 1; "To:   "; CHR$ (64 + u); v
130 STOP
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
700 REM === draw labels ===
710 FOR c = 1 TO 8
720 PRINT AT 1, c * 2 + 2; INK 7; CHR$ (64 + c)
730 NEXT c
740 FOR r = 1 TO 8
750 PRINT AT r + 2, 1; INK 7; r
760 NEXT r
770 RETURN
800 REM === draw status ===
810 PRINT AT 12, 1; INK 7; "                              "
820 IF t = 1 THEN PRINT AT 12, 1; INK 2; "Player 1 (Red)"
830 IF t = 2 THEN PRINT AT 12, 1; INK 4; "Player 2 (Green)"
840 RETURN
850 REM === read input ===
855 PRINT AT 14, 1; "                              "
860 INPUT "Move (e.g. A3 B4): "; m$
870 IF LEN m$ < 5 THEN PRINT AT 14, 1; INK 2; "Use format: A3 B4": GO TO 860
880 LET p = CODE m$(1) - 64
890 LET q = VAL m$(2 TO 2)
900 LET u = CODE m$(4) - 64
910 LET v = VAL m$(5 TO 5)
920 IF p < 1 OR p > 8 OR q < 1 OR q > 8 THEN PRINT AT 14, 1; INK 2; "Invalid source": GO TO 860
930 IF u < 1 OR u > 8 OR v < 1 OR v > 8 THEN PRINT AT 14, 1; INK 2; "Invalid target": GO TO 860
940 RETURN
