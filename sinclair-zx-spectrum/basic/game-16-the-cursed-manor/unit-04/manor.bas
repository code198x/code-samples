5 REM === THE CURSED MANOR ===
10 BORDER 0: PAPER 0: INK 7: CLS
12 LET r = 1
14 DIM e(3,4)
16 REM exits: N S E W
18 LET e(1,1) = 2: LET e(1,3) = 3
20 LET e(2,2) = 1
22 LET e(3,4) = 1
24 GO SUB 700
30 REM === main loop ===
32 PRINT AT 20, 0; INK 7; "> ";
40 INPUT LINE i$
42 IF i$ = "" THEN GO TO 30
44 REM parse direction
46 LET y$ = ""
48 IF i$ = "GO NORTH" OR i$ = "go north" THEN LET y$ = "NORTH"
50 IF i$ = "GO SOUTH" OR i$ = "go south" THEN LET y$ = "SOUTH"
52 IF i$ = "GO EAST" OR i$ = "go east" THEN LET y$ = "EAST"
54 IF i$ = "GO WEST" OR i$ = "go west" THEN LET y$ = "WEST"
56 IF y$ = "" THEN PRINT AT 18, 0; INK 2; "I do not understand that.": GO TO 30
58 GO SUB 300
60 GO TO 30
300 REM === go direction ===
302 LET n = 0
304 IF y$ = "NORTH" THEN LET n = e(r,1)
306 IF y$ = "SOUTH" THEN LET n = e(r,2)
308 IF y$ = "EAST" THEN LET n = e(r,3)
310 IF y$ = "WEST" THEN LET n = e(r,4)
312 IF n = 0 THEN PRINT AT 18, 0; INK 2; "You cannot go that way.": RETURN
314 LET r = n
316 CLS: GO SUB 700
318 RETURN
700 REM === display room ===
702 IF r = 1 THEN PRINT AT 0, 0; INK 7; BRIGHT 1; "Entrance Hall": PRINT AT 2, 0; INK 5; "A grand hall. A chandelier hangs still."
704 IF r = 2 THEN PRINT AT 0, 0; INK 7; BRIGHT 1; "Drawing Room": PRINT AT 2, 0; INK 5; "Firelight flickers on faded wallpaper."
706 IF r = 3 THEN PRINT AT 0, 0; INK 7; BRIGHT 1; "Dining Room": PRINT AT 2, 0; INK 5; "A long table set for dinner."
710 PRINT AT 10, 0; INK 7; "Exits: ";
712 IF e(r,1) <> 0 THEN PRINT "N ";
714 IF e(r,2) <> 0 THEN PRINT "S ";
716 IF e(r,3) <> 0 THEN PRINT "E ";
718 IF e(r,4) <> 0 THEN PRINT "W ";
720 PRINT
722 RETURN
