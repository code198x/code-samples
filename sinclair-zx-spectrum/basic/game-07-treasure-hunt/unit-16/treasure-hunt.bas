10 REM Treasure Hunt
20 BORDER 0
30 PAPER 0
40 INK 7
50 CLS
60 INK 6
70 PRINT AT 3, 8; "TREASURE HUNT"
80 INK 7
90 PRINT AT 7, 4; "Collect all the coins to"
100 PRINT AT 8, 4; "clear each level."
110 PRINT AT 11, 4; "Avoid the hazards! They"
120 PRINT AT 12, 4; "cost you a life."
130 PRINT AT 15, 4; "Controls:"
140 PRINT AT 16, 6; INK 5; "Q"; INK 7; " Up    "; INK 5; "A"; INK 7; " Down"
150 PRINT AT 17, 6; INK 5; "O"; INK 7; " Left   "; INK 5; "P"; INK 7; " Right"
160 INK 3: PRINT AT 20, 5; "Press any key to play": INK 7
170 IF INKEY$ = "" THEN GO TO 170
180 LET r = 10: LET c = 15
190 LET n = 0: LET v = 3: LET l = 1
200 GO SUB 1000
210 LET m = 500
220 LET t = PEEK 23672 + 256 * PEEK 23673
230 REM === game loop ===
240 INK 4: BRIGHT 1: PRINT AT r, c; "O": BRIGHT 0: INK 7
250 LET e = PEEK 23672 + 256 * PEEK 23673
260 LET d = INT ((e - t) / 50)
270 LET w = m - d
280 IF w < 0 THEN LET w = 0
290 PRINT AT 0, 0; "L:"; l; " C:"; f; " V:"; v; " T:"; w; "  "
300 IF w = 0 THEN GO TO 600
310 LET k$ = INKEY$
320 IF k$ = "" THEN GO TO 240
330 PRINT AT r, c; " "
340 LET u = r: LET z = c
350 IF k$ = "q" THEN LET u = r - 1
360 IF k$ = "a" THEN LET u = r + 1
370 IF k$ = "o" THEN LET z = c - 1
380 IF k$ = "p" THEN LET z = c + 1
390 IF u < 2 OR u > 20 THEN LET u = r
400 IF z < 1 OR z > 30 THEN LET z = c
410 LET a = ATTR (u, z)
420 IF a = 5 THEN GO TO 240
430 LET r = u: LET c = z
440 IF a = 6 THEN LET n = n + 1: LET f = f - 1: BEEP 0.05, 20
450 IF a = 2 THEN GO SUB 1500
460 INK 4: BRIGHT 1: PRINT AT r, c; "O": BRIGHT 0: INK 7
470 IF v = 0 THEN GO TO 600
480 IF f = 0 THEN GO SUB 1600
490 GO TO 240
600 REM === game over ===
610 CLS
620 INK 2: PRINT AT 5, 10; "GAME OVER": INK 7
630 PRINT AT 8, 8; "Level: "; l
640 PRINT AT 9, 8; "Coins: "; n
650 IF n >= 30 THEN PRINT AT 12, 6; "Amazing treasure hunter!"
660 IF n >= 15 AND n < 30 THEN PRINT AT 12, 8; "Well done!"
670 IF n < 15 THEN PRINT AT 12, 6; "Better luck next time!"
680 BEEP 0.2, 7: BEEP 0.2, 5: BEEP 0.2, 2: BEEP 0.4, 0
690 INK 3: PRINT AT 20, 5; "Press any key to exit": INK 7
700 IF INKEY$ <> "" THEN GO TO 700
710 IF INKEY$ = "" THEN GO TO 710
720 BORDER 7: PAPER 7: INK 0: CLS
730 STOP
1000 REM === draw arena ===
1010 CLS
1020 INK 3
1030 FOR i = 0 TO 31
1040 PRINT AT 1, i; "="
1050 PRINT AT 21, i; "="
1060 NEXT i
1070 FOR i = 1 TO 21
1080 PRINT AT i, 0; "|"
1090 PRINT AT i, 31; "|"
1100 NEXT i
1110 INK 7
1120 GO SUB 1200
1130 GO SUB 1300
1140 RETURN
1200 REM === place coins ===
1210 LET g = 5 + l * 2
1220 LET f = g
1230 FOR i = 1 TO g
1240 LET y = INT (RND * 18) + 2
1250 LET x = INT (RND * 29) + 1
1260 IF ATTR (y, x) <> 7 THEN GO TO 1240
1270 INK 6: PRINT AT y, x; "*": INK 7
1280 NEXT i
1290 RETURN
1300 REM === place hazards ===
1310 FOR i = 1 TO l + 1
1320 LET y = INT (RND * 18) + 2
1330 LET x = INT (RND * 29) + 1
1340 IF ATTR (y, x) <> 7 THEN GO TO 1320
1350 INK 2: PRINT AT y, x; "#": INK 7
1360 NEXT i
1370 RETURN
1500 REM === lose life ===
1510 LET v = v - 1
1520 BEEP 0.1, 0: BEEP 0.1, -3: BEEP 0.2, -7
1530 LET r = 10: LET c = 15
1540 RETURN
1600 REM === next level ===
1610 LET l = l + 1
1620 LET m = 500 - l * 20
1630 BEEP 0.15, 12: BEEP 0.15, 16: BEEP 0.3, 19
1640 CLS
1650 INK 6: PRINT AT 10, 10; "Level "; l; "!": INK 7
1660 PAUSE 75
1670 GO SUB 1000
1680 LET r = 10: LET c = 15
1690 LET t = PEEK 23672 + 256 * PEEK 23673
1700 RETURN
