5 REM === DRAUGHTS ===
10 BORDER 0: PAPER 0: INK 7: CLS
15 GO SUB 1500
20 DIM b(8, 8)
25 LET g = 0: LET h = 0
30 GO SUB 400
40 GO SUB 500
50 GO SUB 600
60 GO SUB 700
70 LET t = 1
80 REM game loop
85 GO SUB 1400
90 GO SUB 800
100 PRINT AT 15, 1; "                              "
110 GO SUB 850
120 GO SUB 900
130 GO SUB 950
140 GO SUB 1000
145 GO SUB 1300
150 GO TO 80
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
630 IF b(r, c) = 0 THEN GO TO 680
640 IF b(r, c) = 1 THEN PRINT AT r + 2, c * 2 + 2; PAPER 0; INK 2; "o"
650 IF b(r, c) = 2 THEN PRINT AT r + 2, c * 2 + 2; PAPER 0; INK 4; "o"
660 IF b(r, c) = 3 THEN PRINT AT r + 2, c * 2 + 2; PAPER 0; INK 2; BRIGHT 1; "K"
670 IF b(r, c) = 4 THEN PRINT AT r + 2, c * 2 + 2; PAPER 0; INK 4; BRIGHT 1; "K"
680 NEXT c
690 NEXT r
695 RETURN
700 REM === draw labels ===
710 FOR c = 1 TO 8
720 PRINT AT 1, c * 2 + 2; INK 7; CHR$ (64 + c)
730 NEXT c
740 FOR r = 1 TO 8
750 PRINT AT r + 2, 1; INK 7; r
760 NEXT r
770 RETURN
800 REM === draw status ===
810 PRINT AT 12, 1; "                              "
820 IF t = 1 THEN PRINT AT 12, 1; INK 2; "Player 1 (Red)"
830 IF t = 2 THEN PRINT AT 12, 1; INK 4; "Player 2 (Green)"
835 PRINT AT 13, 1; INK 7; "Captured: "; INK 2; g; INK 7; " - "; INK 4; h; "  "
840 RETURN
850 REM === read input ===
852 PRINT AT 14, 1; "                              "
854 INPUT "Move (e.g. A3 B4): "; m$
856 IF LEN m$ < 5 THEN PRINT AT 15, 1; INK 2; "Use format: A3 B4": GO TO 854
860 LET p = CODE m$(1) - 64
862 LET q = VAL m$(2 TO 2)
864 LET u = CODE m$(4) - 64
866 LET v = VAL m$(5 TO 5)
870 IF p < 1 OR p > 8 OR q < 1 OR q > 8 THEN PRINT AT 15, 1; INK 2; "Invalid square": GO TO 854
872 IF u < 1 OR u > 8 OR v < 1 OR v > 8 THEN PRINT AT 15, 1; INK 2; "Invalid square": GO TO 854
880 RETURN
900 REM === validate source ===
910 IF b(q, p) = 0 THEN PRINT AT 15, 1; INK 2; "No piece there      ": GO TO 854
920 IF t = 1 AND b(q, p) <> 1 AND b(q, p) <> 3 THEN PRINT AT 15, 1; INK 2; "Not your piece      ": GO TO 854
930 IF t = 2 AND b(q, p) <> 2 AND b(q, p) <> 4 THEN PRINT AT 15, 1; INK 2; "Not your piece      ": GO TO 854
940 RETURN
950 REM === check move ===
955 LET j = 0
960 LET e = ABS (u - p): LET f = ABS (v - q)
962 IF e = 2 AND f = 2 THEN GO TO 1100
970 IF e <> 1 OR f <> 1 THEN PRINT AT 15, 1; INK 2; "Invalid move        ": GO TO 854
975 IF b(v, u) <> 0 THEN PRINT AT 15, 1; INK 2; "Square occupied     ": GO TO 854
980 IF b(q, p) < 3 AND t = 1 AND v < q THEN PRINT AT 15, 1; INK 2; "Must move forward   ": GO TO 854
990 IF b(q, p) < 3 AND t = 2 AND v > q THEN PRINT AT 15, 1; INK 2; "Must move forward   ": GO TO 854
995 RETURN
1000 REM === make move ===
1010 LET b(v, u) = b(q, p)
1020 LET b(q, p) = 0
1025 IF t = 1 AND v = 8 AND b(v, u) = 1 THEN LET b(v, u) = 3: BEEP 0.1, 20: BEEP 0.1, 24
1026 IF t = 2 AND v = 1 AND b(v, u) = 2 THEN LET b(v, u) = 4: BEEP 0.1, 20: BEEP 0.1, 24
1030 GO SUB 1200
1035 IF j = 0 THEN GO TO 1060
1040 LET w = (q + v) / 2: LET x = (p + u) / 2
1045 LET b(w, x) = 0
1050 PRINT AT w + 2, x * 2 + 2; PAPER 0; " "
1055 BEEP 0.1, 5
1057 IF t = 1 THEN LET g = g + 1: GO TO 1060
1058 LET h = h + 1
1060 BEEP 0.05, 10
1070 IF t = 1 THEN LET t = 2: RETURN
1080 LET t = 1
1090 RETURN
1100 REM === check capture ===
1110 IF b(v, u) <> 0 THEN PRINT AT 15, 1; INK 2; "Square occupied     ": GO TO 854
1120 LET w = (q + v) / 2: LET x = (p + u) / 2
1130 IF b(w, x) = 0 THEN PRINT AT 15, 1; INK 2; "Nothing to jump     ": GO TO 854
1140 IF t = 1 AND b(w, x) <> 2 AND b(w, x) <> 4 THEN PRINT AT 15, 1; INK 2; "Can only jump enemy ": GO TO 854
1150 IF t = 2 AND b(w, x) <> 1 AND b(w, x) <> 3 THEN PRINT AT 15, 1; INK 2; "Can only jump enemy ": GO TO 854
1160 IF b(q, p) < 3 AND t = 1 AND v < q THEN PRINT AT 15, 1; INK 2; "Must jump forward   ": GO TO 854
1170 IF b(q, p) < 3 AND t = 2 AND v > q THEN PRINT AT 15, 1; INK 2; "Must jump forward   ": GO TO 854
1180 LET j = 1
1190 RETURN
1200 REM === draw cell ===
1210 PRINT AT q + 2, p * 2 + 2; PAPER 0; " "
1220 IF b(v, u) = 1 THEN PRINT AT v + 2, u * 2 + 2; PAPER 0; INK 2; "o"
1230 IF b(v, u) = 2 THEN PRINT AT v + 2, u * 2 + 2; PAPER 0; INK 4; "o"
1240 IF b(v, u) = 3 THEN PRINT AT v + 2, u * 2 + 2; PAPER 0; INK 2; BRIGHT 1; "K"
1250 IF b(v, u) = 4 THEN PRINT AT v + 2, u * 2 + 2; PAPER 0; INK 4; BRIGHT 1; "K"
1260 RETURN
1300 REM === check win ===
1310 LET a = 0: LET d = 0
1320 FOR r = 1 TO 8
1330 FOR c = 1 TO 8
1340 IF b(r, c) = 1 OR b(r, c) = 3 THEN LET a = a + 1
1350 IF b(r, c) = 2 OR b(r, c) = 4 THEN LET d = d + 1
1360 NEXT c
1370 NEXT r
1380 IF a = 0 THEN PRINT AT 17, 1; INK 4; BRIGHT 1; "Player 2 wins!": BEEP 0.2, 12: BEEP 0.2, 16: BEEP 0.3, 19: STOP
1390 IF d = 0 THEN PRINT AT 17, 1; INK 2; BRIGHT 1; "Player 1 wins!": BEEP 0.2, 12: BEEP 0.2, 16: BEEP 0.3, 19: STOP
1395 RETURN
1400 REM === check no moves ===
1405 LET n = 0
1410 FOR r = 1 TO 8
1420 FOR c = 1 TO 8
1425 IF t = 1 AND b(r, c) <> 1 AND b(r, c) <> 3 THEN GO TO 1470
1430 IF t = 2 AND b(r, c) <> 2 AND b(r, c) <> 4 THEN GO TO 1470
1435 LET i = -1
1440 LET k = -1
1445 IF r + i < 1 OR r + i > 8 OR c + k < 1 OR c + k > 8 THEN GO TO 1455
1447 IF b(r + i, c + k) = 0 THEN LET n = 1: GO TO 1480
1450 IF r + i * 2 >= 1 AND r + i * 2 <= 8 AND c + k * 2 >= 1 AND c + k * 2 <= 8 THEN IF b(r + i * 2, c + k * 2) = 0 AND b(r + i, c + k) <> 0 THEN LET n = 1: GO TO 1480
1455 LET k = k + 2: IF k <= 1 THEN GO TO 1445
1460 LET i = i + 2: IF i <= 1 THEN LET k = -1: GO TO 1445
1470 NEXT c
1475 NEXT r
1480 IF n = 0 AND t = 1 THEN PRINT AT 17, 1; INK 4; BRIGHT 1; "Player 2 wins!": PRINT AT 18, 1; "No moves for Red": BEEP 0.2, 0: BEEP 0.2, -3: BEEP 0.3, -7: STOP
1485 IF n = 0 AND t = 2 THEN PRINT AT 17, 1; INK 2; BRIGHT 1; "Player 1 wins!": PRINT AT 18, 1; "No moves for Green": BEEP 0.2, 0: BEEP 0.2, -3: BEEP 0.3, -7: STOP
1490 RETURN
1500 REM === title screen ===
1510 PRINT AT 4, 10; INK 7; BRIGHT 1; "DRAUGHTS"
1520 PRINT AT 7, 4; INK 2; "o"; INK 7; " = Player 1 (Red)"
1530 PRINT AT 8, 4; INK 4; "o"; INK 7; " = Player 2 (Green)"
1540 PRINT AT 10, 4; INK 2; BRIGHT 1; "K"; INK 7; " = King (any direction)"
1550 PRINT AT 12, 2; INK 5; "Enter moves like: A3 B4"
1560 PRINT AT 13, 2; INK 5; "Captures jump: A3 C5"
1570 PRINT AT 16, 2; INK 7; "Player 1 moves first."
1580 PRINT AT 19, 5; INK 7; "Press any key"
1590 PAUSE 0
1595 CLS
1598 RETURN
