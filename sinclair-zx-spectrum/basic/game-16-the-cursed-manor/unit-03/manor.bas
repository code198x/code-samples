5 REM === THE CURSED MANOR ===
10 BORDER 0: PAPER 0: INK 7: CLS
12 LET r = 1
14 GO SUB 700
20 REM === main loop ===
30 PRINT AT 20, 0; INK 7; "> ";
40 INPUT LINE i$
42 IF i$ = "" THEN GO TO 20
50 IF i$ = "GO NORTH" OR i$ = "go north" THEN GO SUB 300: GO TO 20
52 IF i$ = "GO SOUTH" OR i$ = "go south" THEN GO SUB 310: GO TO 20
60 PRINT AT 18, 0; INK 2; "I do not understand that."
70 GO TO 20
300 REM === go north ===
302 IF r = 1 THEN LET r = 2: CLS: GO SUB 700: RETURN
304 PRINT AT 18, 0; INK 2; "You cannot go that way.": RETURN
310 REM === go south ===
312 IF r = 2 THEN LET r = 1: CLS: GO SUB 700: RETURN
314 PRINT AT 18, 0; INK 2; "You cannot go that way.": RETURN
700 REM === display room ===
702 IF r = 1 THEN PRINT AT 0, 0; INK 7; BRIGHT 1; "Entrance Hall": PRINT AT 2, 0; INK 5; "A grand hall. A chandelier hangs still."
704 IF r = 2 THEN PRINT AT 0, 0; INK 7; BRIGHT 1; "Drawing Room": PRINT AT 2, 0; INK 5; "Firelight flickers on faded wallpaper."
706 IF r = 1 THEN PRINT AT 10, 0; INK 7; "Exits: N "
708 IF r = 2 THEN PRINT AT 10, 0; INK 7; "Exits: S "
710 RETURN
