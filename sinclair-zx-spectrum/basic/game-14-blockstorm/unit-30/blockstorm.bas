5 REM === HIGH SCORE TABLE ===
10 BORDER 0: PAPER 0: INK 7: CLS
15 GO SUB 800
20 LET sc = 0: LET hi = 0: LET li = 3
22 LET wv = 1: LET tw = 5
24 LET el = 0: LET pw = 0: LET sh = 0
25 DIM e(20): DIM r(20): DIM t(20): DIM h(20)
27 DIM b(2): DIM c(2): DIM d(2)
28 DIM m(3): DIM n(3): DIM o(3)
30 GO SUB 2500
40 REM === load wave ===
42 RESTORE 900
44 FOR i = 1 TO wv - 1
46 READ ne, nr, sp
48 FOR j = 1 TO ne: READ a, a, a, a: NEXT j
50 NEXT i
52 READ ne, nr, sp
54 FOR i = 1 TO ne
56 READ e(i), r(i), t(i), h(i)
58 NEXT i
60 LET fx = 10: LET fy = 2: LET fd = 1
62 LET px = 15: LET py = 20
64 LET tk = 0
66 FOR i = 1 TO 2: LET d(i) = 0: NEXT i
68 FOR i = 1 TO 3: LET o(i) = 0: NEXT i
70 CLS
72 GO SUB 600
75 GO SUB 500
80 REM === game loop ===
85 LET k$ = INKEY$
90 IF k$ = "o" OR k$ = "O" THEN GO SUB 300
95 IF k$ = "p" OR k$ = "P" THEN GO SUB 310
100 IF k$ = " " THEN GO SUB 320
105 GO SUB 350
110 LET tk = tk + 1
115 IF tk >= sp THEN GO SUB 400: LET tk = 0
120 GO SUB 450
125 GO SUB 550
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
352 FOR i = 1 TO 2
354 IF d(i) = 0 THEN GO TO 396
356 PRINT AT c(i), b(i); " "
358 LET c(i) = c(i) - 1
360 IF c(i) < 1 THEN LET d(i) = 0: GO TO 396
362 REM check hit
364 LET ht = 0
366 FOR j = 1 TO ne
368 IF h(j) <= 0 THEN GO TO 385
370 LET sx = fx + e(j): LET sy = fy + r(j)
372 IF b(i) = sx AND c(i) = sy THEN LET ht = j: GO TO 386
385 NEXT j
386 IF ht = 0 THEN PRINT AT c(i), b(i); INK 7; CHR$ 148: GO TO 396
388 LET d(i) = 0
390 LET h(ht) = h(ht) - 1
391 IF h(ht) <= 0 THEN GO SUB 510: GO TO 396
392 PRINT AT fy + r(ht), fx + e(ht); INK 7; CHR$ (143 + t(ht)): BEEP 0.01, 10
394 PAUSE 2: PRINT AT fy + r(ht), fx + e(ht); INK 6; CHR$ (143 + t(ht))
396 NEXT i
398 RETURN
400 REM === move formation ===
402 FOR i = 1 TO ne
404 IF h(i) <= 0 THEN GO TO 420
406 LET sx = fx + e(i): LET sy = fy + r(i)
408 IF sx >= 1 AND sx <= 30 AND sy >= 1 AND sy <= 21 THEN PRINT AT sy, sx; " "
420 NEXT i
422 LET fx = fx + fd
424 IF fx + 10 > 30 OR fx < 1 THEN LET fd = -fd: LET fy = fy + 1
426 IF fy + nr > 19 THEN GO TO 700
428 FOR i = 1 TO ne
430 IF h(i) <= 0 THEN GO TO 445
432 LET sx = fx + e(i): LET sy = fy + r(i)
434 IF sx < 1 OR sx > 30 OR sy < 1 OR sy > 21 THEN GO TO 445
436 LET ci = 4
438 IF t(i) = 2 THEN LET ci = 5
439 IF t(i) = 3 THEN LET ci = 6
440 IF t(i) = 4 THEN LET ci = 3
442 PRINT AT sy, sx; INK ci; CHR$ (143 + t(i))
445 NEXT i
447 RETURN
450 REM === move bombs ===
452 FOR i = 1 TO 3
454 IF o(i) = 0 THEN GO TO 480
456 PRINT AT n(i), m(i); " "
458 LET n(i) = n(i) + 1
460 IF n(i) > 21 THEN LET o(i) = 0: GO TO 480
462 IF m(i) = px AND n(i) = py THEN GO SUB 530: LET o(i) = 0: GO TO 480
464 PRINT AT n(i), m(i); INK 2; CHR$ 153
480 NEXT i
484 FOR i = 1 TO ne
486 IF h(i) <= 0 OR t(i) <> 4 THEN GO TO 496
488 IF INT (RND * 30) <> 0 THEN GO TO 496
490 FOR j = 1 TO 3
492 IF o(j) = 0 THEN LET m(j) = fx + e(i): LET n(j) = fy + r(i) + 1: LET o(j) = 1: LET j = 3
494 NEXT j
496 NEXT i
498 RETURN
500 REM === draw player ===
505 PRINT AT py, px; INK 7; CHR$ 152
508 RETURN
510 REM === enemy destroyed ===
512 LET sx = fy + r(ht): LET sy = fx + e(ht)
514 PRINT AT sx, sy; INK 2; CHR$ 149
516 BEEP 0.02, -5: BEEP 0.02, -10
518 LET pt = 10
519 IF t(ht) = 2 THEN LET pt = 25
520 IF t(ht) = 3 THEN LET pt = 50
521 IF t(ht) = 4 THEN LET pt = 30
522 LET sc = sc + pt
524 IF sc > hi THEN LET hi = sc
526 IF el = 0 AND sc >= 2000 THEN LET li = li + 1: LET el = 1: BEEP 0.1, 15: BEEP 0.1, 19
528 RETURN
530 REM === player hit ===
532 IF sh = 1 THEN LET sh = 0: BEEP 0.05, 5: RETURN
534 LET li = li - 1
536 PRINT AT py, px; INK 2; CHR$ 149
538 BEEP 0.1, -10: BEEP 0.1, -15
540 PAUSE 25
542 PRINT AT py, px; " "
544 IF li <= 0 THEN GO TO 700
546 LET px = 15
548 GO SUB 500
549 RETURN
550 REM === check power-ups ===
552 RETURN
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
664 LET sc = sc + wv * 50
666 BEEP 0.1, 12: BEEP 0.1, 16: BEEP 0.2, 19
668 GO SUB 600
670 PAUSE 50
672 LET wv = wv + 1
674 IF wv > tw THEN GO TO 750
676 GO TO 40
700 REM === game over ===
705 CLS
710 PRINT AT 8, 10; INK 2; BRIGHT 1; "GAME OVER"
715 PRINT AT 10, 7; INK 7; "Score: "; sc
720 PRINT AT 12, 7; INK 7; "Wave: "; wv
725 PRINT AT 14, 7; INK 7; "High: "; hi
730 PRINT AT 18, 6; INK 7; "Press any key"
735 PAUSE 0
740 LET li = 3: LET sc = 0: LET wv = 1
742 LET el = 0: LET pw = 0: LET sh = 0
745 GO TO 20
750 REM === game complete ===
755 CLS
760 PRINT AT 6, 7; INK 7; BRIGHT 1; "CONGRATULATIONS!"
765 PRINT AT 8, 5; INK 6; "All "; tw; " waves defeated!"
770 PRINT AT 10, 7; INK 7; "Final score: "; sc
775 PRINT AT 14, 6; INK 7; "Press any key"
780 PAUSE 0
785 GO TO 700
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
900 REM === WAVE DATA ===
902 REM wave 1: 8 drones, 1 row, speed 4
904 DATA 8, 1, 4
906 DATA 0,0,1,1, 2,0,1,1, 4,0,1,1, 6,0,1,1, 8,0,1,1, 10,0,1,1, 12,0,1,1, 14,0,1,1
910 REM wave 2: 10 drones, 2 rows, speed 4
912 DATA 10, 2, 4
914 DATA 0,0,1,1, 2,0,1,1, 4,0,1,1, 6,0,1,1, 8,0,1,1, 0,1,1,1, 2,1,1,1, 4,1,1,1, 6,1,1,1, 8,1,1,1
920 REM wave 3: 10 mixed, 2 rows, speed 3
922 DATA 10, 2, 3
924 DATA 0,0,1,1, 2,0,1,1, 4,0,1,1, 6,0,1,1, 8,0,1,1, 1,1,2,1, 3,1,1,1, 5,1,2,1, 7,1,1,1, 9,1,1,1
930 REM wave 4: 12 mixed, 3 rows, speed 3
932 DATA 12, 3, 3
934 DATA 4,0,1,1, 6,0,1,1, 3,1,1,1, 5,1,2,1, 7,1,1,1, 2,2,1,1, 4,2,1,1, 6,2,1,1, 8,2,1,1, 1,1,1,1, 9,1,1,1, 5,0,3,2
940 REM wave 5: 14 mixed with bombers, speed 2
942 DATA 14, 3, 2
944 DATA 0,0,1,1, 2,0,1,1, 4,0,4,1, 6,0,1,1, 8,0,4,1, 10,0,1,1, 12,0,1,1, 0,1,2,1, 4,1,3,2, 8,1,2,1, 12,1,1,1, 2,2,1,1, 6,2,1,1, 10,2,1,1
2500 REM === title screen ===
2510 PRINT AT 3, 8; INK 7; BRIGHT 1; "BLOCKSTORM"
2520 PRINT AT 6, 2; INK 6; "Alien blocks descend in"
2525 PRINT AT 7, 2; INK 6; "waves. Shoot them down!"
2530 PRINT AT 9, 2; INK 7; "O/P = move left/right"
2535 PRINT AT 10, 2; INK 7; "SPACE = fire"
2540 PRINT AT 12, 2; INK 5; "Enemies:"
2545 PRINT AT 13, 4; INK 4; CHR$ 144; INK 7; " Drone (10pts)"
2550 PRINT AT 14, 4; INK 5; CHR$ 145; INK 7; " Scout (25pts)"
2555 PRINT AT 15, 4; INK 6; CHR$ 146; INK 7; " Tank  (50pts)"
2560 PRINT AT 16, 4; INK 3; CHR$ 147; INK 7; " Bomber(30pts)"
2570 PRINT AT 18, 2; INK 4; "3 lives. "; tw; " waves."
2580 PRINT AT 20, 6; INK 7; "Press any key"
2590 PAUSE 0
2595 CLS
2598 RETURN
