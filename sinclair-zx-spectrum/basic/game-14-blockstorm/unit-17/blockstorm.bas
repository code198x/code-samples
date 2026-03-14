5 REM === SCOUT BEHAVIOUR ===
10 BORDER 0: PAPER 0: INK 7: CLS
15 GO SUB 800
20 LET sc = 0: LET hi = 0: LET li = 3
22 LET wv = 1: LET ne = 8: LET sp = 4
24 LET nr = 1
25 DIM e(8): DIM r(8): DIM t(8): DIM h(8)
27 DIM b(1): DIM c(1): DIM d(1)
30 REM set up 6 drones and 2 scouts
32 FOR i = 1 TO 6
34 LET e(i) = (i - 1) * 2: LET r(i) = 0: LET t(i) = 1: LET h(i) = 1
36 NEXT i
38 LET e(7) = 2: LET r(7) = 1: LET t(7) = 2: LET h(7) = 1
39 LET e(8) = 8: LET r(8) = 1: LET t(8) = 2: LET h(8) = 1
40 LET fx = 10: LET fy = 2: LET fd = 1: LET tk = 0
42 LET px = 15: LET py = 20
44 LET d(1) = 0
50 CLS
52 GO SUB 600
55 GO SUB 500
80 REM === game loop ===
85 LET k$ = INKEY$
90 IF k$ = "o" OR k$ = "O" THEN GO SUB 300
95 IF k$ = "p" OR k$ = "P" THEN GO SUB 310
100 IF k$ = " " THEN GO SUB 320
105 GO SUB 350
110 LET tk = tk + 1
115 IF tk >= sp THEN GO SUB 400: LET tk = 0
120 IF fy + nr > 19 THEN GO TO 700
130 GO SUB 600
135 GO SUB 650
140 GO TO 80
300 REM === move left ===
302 IF px <= 1 THEN RETURN
304 PRINT AT py, px; " "
306 LET px = px - 1
308 PRINT AT py, px; INK 7; CHR$ 152
309 RETURN
310 REM === move right ===
312 IF px >= 30 THEN RETURN
314 PRINT AT py, px; " "
316 LET px = px + 1
318 PRINT AT py, px; INK 7; CHR$ 152
319 RETURN
320 REM === fire ===
322 IF d(1) = 1 THEN RETURN
324 LET b(1) = px: LET c(1) = py - 1: LET d(1) = 1
326 PRINT AT c(1), b(1); INK 7; CHR$ 148
328 BEEP 0.01, 20
329 RETURN
350 REM === move bullets ===
352 IF d(1) = 0 THEN RETURN
354 PRINT AT c(1), b(1); " "
356 LET c(1) = c(1) - 1
358 IF c(1) < 1 THEN LET d(1) = 0: RETURN
360 LET ht = 0
364 FOR j = 1 TO ne
366 IF h(j) <= 0 THEN GO TO 380
368 LET sx = fx + e(j): LET sy = fy + r(j)
370 IF b(1) = sx AND c(1) = sy THEN LET ht = j: GO TO 382
380 NEXT j
382 IF ht = 0 THEN PRINT AT c(1), b(1); INK 7; CHR$ 148: RETURN
384 LET d(1) = 0: LET h(ht) = 0
386 PRINT AT fy + r(ht), fx + e(ht); INK 2; CHR$ 149
388 BEEP 0.02, -5: BEEP 0.02, -10
390 LET pt = 10
391 IF t(ht) = 2 THEN LET pt = 25
392 LET sc = sc + pt: IF sc > hi THEN LET hi = sc
396 RETURN
400 REM === move formation ===
402 FOR i = 1 TO ne
404 IF h(i) <= 0 THEN GO TO 420
406 LET sx = fx + e(i): LET sy = fy + r(i)
408 IF sx >= 1 AND sx <= 30 AND sy >= 1 AND sy <= 21 THEN PRINT AT sy, sx; " "
420 NEXT i
422 LET fx = fx + fd
424 IF fx + 10 > 30 OR fx < 1 THEN LET fd = -fd: LET fy = fy + 1
428 FOR i = 1 TO ne
430 IF h(i) <= 0 THEN GO TO 445
432 LET sx = fx + e(i): LET sy = fy + r(i)
434 IF sx < 1 OR sx > 30 OR sy < 1 OR sy > 21 THEN GO TO 445
436 LET ci = 4
438 IF t(i) = 2 THEN LET ci = 5
442 PRINT AT sy, sx; INK ci; CHR$ (143 + t(i))
445 NEXT i
447 RETURN
500 REM === draw player ===
505 PRINT AT py, px; INK 7; CHR$ 152
508 RETURN
530 REM === player hit ===
534 LET li = li - 1
536 PRINT AT py, px; INK 2; CHR$ 149
538 BEEP 0.1, -10: BEEP 0.1, -15
540 PAUSE 25
542 PRINT AT py, px; " "
544 IF li <= 0 THEN GO TO 700
546 LET px = 15
548 GO SUB 500
549 RETURN
600 REM === draw HUD ===
605 PRINT AT 0, 0; INK 7; BRIGHT 1; "SC:"; sc; "  HI:"; hi; "  LV:"; li; " W"; wv; "  "
610 RETURN
650 REM === check wave clear ===
652 LET w = 0
654 FOR i = 1 TO ne
656 IF h(i) > 0 THEN LET w = 1
658 NEXT i
660 IF w = 1 THEN RETURN
662 PRINT AT 10, 9; INK 7; BRIGHT 1; "WAVE CLEAR!"
664 BEEP 0.1, 12: BEEP 0.1, 16: BEEP 0.2, 19
670 PAUSE 50
685 RETURN
700 REM === game over ===
705 CLS
710 PRINT AT 8, 10; INK 2; BRIGHT 1; "GAME OVER"
715 PRINT AT 10, 7; INK 7; "Score: "; sc
720 PRINT AT 12, 7; INK 7; "High: "; hi
730 PRINT AT 18, 6; INK 7; "Press any key"
735 PAUSE 0
740 LET li = 3: LET sc = 0
745 GO TO 20
800 REM === define UDGs ===
805 FOR i = 0 TO 13
810 FOR j = 0 TO 7
815 READ a
820 POKE USR CHR$ (65 + i) + j, a
825 NEXT j
830 NEXT i
835 RETURN
840 REM UDG A: drone
842 DATA 36, 126, 219, 255, 255, 102, 66, 0
844 REM UDG B: scout
846 DATA 24, 60, 126, 255, 219, 24, 36, 0
848 REM UDG C: tank
850 DATA 126, 255, 255, 255, 255, 255, 126, 0
852 REM UDG D: bomber
854 DATA 66, 231, 255, 126, 60, 90, 36, 0
856 REM UDG E: bullet
858 DATA 16, 56, 16, 16, 0, 0, 0, 0
860 REM UDG F: explosion
862 DATA 36, 153, 66, 129, 66, 153, 36, 0
864 REM UDG G: double shot
866 DATA 84, 170, 84, 170, 84, 170, 84, 0
868 REM UDG H: shield
870 DATA 60, 126, 255, 255, 255, 126, 60, 0
872 REM UDG I: player ship
874 DATA 16, 56, 56, 124, 254, 254, 130, 0
876 REM UDG J: enemy bomb
878 DATA 16, 16, 56, 16, 0, 0, 0, 0
880 REM UDG K: explosion 2
882 DATA 129, 66, 36, 0, 36, 66, 129, 0
884 REM UDG L: shield icon
886 DATA 60, 126, 126, 126, 60, 24, 0, 0
888 REM UDG M: drone frame 2
890 DATA 66, 102, 255, 255, 219, 126, 36, 0
892 REM UDG N: scout frame 2
894 DATA 36, 24, 219, 255, 126, 60, 24, 0
