5 REM === THE CURSED MANOR ===
10 BORDER 0: PAPER 0: INK 7: CLS
12 LET r = 1: LET v = 0: LET t = 0
14 DIM r$(20,20): DIM d$(20,60)
16 DIM e(20,6): DIM w(20)
18 DIM s$(1,15): DIM q(1)
20 GO SUB 3000
22 LET w(1) = 1
24 GO SUB 700
30 REM === main loop ===
32 PRINT AT 20, 0; INK 7; "> ";
40 INPUT LINE i$
42 IF i$ = "" THEN GO TO 30
44 LET t = t + 1
46 GO SUB 200
48 GO TO 30
200 REM === parser ===
202 LET n = 0
204 FOR i = 1 TO LEN i$
206 IF i$(i) = " " THEN LET n = i: LET i = LEN i$
208 NEXT i
210 IF n = 0 THEN LET x$ = i$: LET y$ = ""
212 IF n > 0 THEN LET x$ = i$(1 TO n - 1): LET y$ = i$(n + 1 TO )
214 REM uppercase
216 FOR i = 1 TO LEN x$
218 LET n = CODE x$(i): IF n >= 97 AND n <= 122 THEN LET x$(i) = CHR$ (n - 32)
220 NEXT i
222 FOR i = 1 TO LEN y$
224 LET n = CODE y$(i): IF n >= 97 AND n <= 122 THEN LET y$(i) = CHR$ (n - 32)
226 NEXT i
228 IF x$ = "GO" THEN GO SUB 300: RETURN
230 IF x$ = "LOOK" THEN CLS: GO SUB 700: RETURN
232 IF x$ = "GET" THEN GO SUB 350: RETURN
234 IF x$ = "SCORE" THEN PRINT AT 18, 0; INK 6; "Score: "; v: RETURN
236 IF x$ = "QUIT" THEN PRINT AT 18, 0; INK 7; "Final score: "; v: STOP
238 PRINT AT 18, 0; INK 2; "I do not understand that."
240 RETURN
300 REM === go direction ===
302 LET n = 0
304 IF y$ = "NORTH" THEN LET n = e(r,1)
306 IF y$ = "SOUTH" THEN LET n = e(r,2)
308 IF y$ = "EAST" THEN LET n = e(r,3)
310 IF y$ = "WEST" THEN LET n = e(r,4)
312 IF y$ = "UP" THEN LET n = e(r,5)
314 IF y$ = "DOWN" THEN LET n = e(r,6)
316 IF n = 0 THEN PRINT AT 18, 0; INK 2; "You cannot go that way.": RETURN
318 IF n = -1 THEN PRINT AT 18, 0; INK 2; "The door is locked.": RETURN
320 IF n = -2 THEN PRINT AT 18, 0; INK 2; "The way is sealed.": RETURN
322 LET r = n: IF w(r) = 0 THEN LET v = v + 1: LET w(r) = 1
324 BEEP 0.02, 5
326 CLS: GO SUB 700
328 RETURN
350 REM === get item ===
352 FOR i = 1 TO 1
354 IF y$ = s$(i) AND q(i) = r THEN LET q(i) = -1: PRINT AT 18, 0; INK 4; "Taken.": BEEP 0.02, 10: RETURN
356 NEXT i
358 PRINT AT 18, 0; INK 2; "I cannot see that here."
360 RETURN
700 REM === display room ===
702 PRINT AT 0, 0; INK 7; BRIGHT 1; r$(r)
704 PRINT AT 2, 0; INK 5; d$(r)
706 FOR i = 1 TO 1
708 IF q(i) = r THEN PRINT AT 6, 0; INK 6; "There is a "; s$(i); " here."
710 NEXT i
712 PRINT AT 10, 0; INK 7; "Exits: ";
714 IF e(r,1) <> 0 THEN PRINT "N ";
716 IF e(r,2) <> 0 THEN PRINT "S ";
718 IF e(r,3) <> 0 THEN PRINT "E ";
720 IF e(r,4) <> 0 THEN PRINT "W ";
722 IF e(r,5) <> 0 THEN PRINT "U ";
724 IF e(r,6) <> 0 THEN PRINT "D ";
726 PRINT
728 RETURN
3000 REM === load data ===
3002 RESTORE 3100
3004 FOR i = 1 TO 20
3006 READ r$(i), d$(i)
3008 READ e(i,1), e(i,2), e(i,3), e(i,4), e(i,5), e(i,6)
3010 NEXT i
3012 LET s$(1) = "KEY": LET q(1) = 6
3014 LET w(1) = 1
3016 RETURN
3100 REM === ROOM DATA ===
3102 DATA "Entrance Hall","A grand hall. A chandelier hangs still.",2,0,3,0,7,0
3104 DATA "Drawing Room","Firelight flickers on faded wallpaper.",0,1,4,0,0,0
3106 DATA "Dining Room","A long table set for dinner.",0,0,5,1,0,0
3108 DATA "Kitchen","A half-prepared meal goes cold.",0,3,0,0,0,12
3110 DATA "Library","Leather and pipe smoke. Books line every wall.",0,0,0,3,0,0
3112 DATA "Conservatory","Moonlight through glass panes. Orchids bloom.",0,5,0,0,0,0
3114 DATA "Landing","The grand staircase leads down.",9,0,8,0,0,1
3116 DATA "Guest Room","A tidy room. Bed still made.",0,0,0,7,0,0
3118 DATA "Master Bedroom","Heavy curtains. A four-poster bed.",0,7,10,0,0,0
3120 DATA "Study","A writing desk faces the window.",0,0,0,9,-1,0
3122 DATA "Billiard Room","Green baize. Cue chalk on the rail.",0,0,0,4,0,0
3124 DATA "Cellar Stairs","Stone steps descend into darkness.",0,0,13,0,4,0
3126 DATA "Wine Cellar","Rows of dusty bottles. Cold air.",14,0,0,12,0,0
3128 DATA "Old Passage","Damp stone. The air is stale.",0,13,-2,0,0,0
3130 DATA "Sealed Chamber","A heavy iron door blocks the way.",0,14,0,0,0,0
3132 DATA "Chapel","An arched window. A stone altar.",0,0,0,6,0,0
3134 DATA "Tower Stairs","A spiral staircase winds upward.",0,0,0,0,18,0
3136 DATA "Tower Study","A lectern holds an open grimoire.",0,0,0,0,0,17
3138 DATA "Stable Yard","Cobblestones and cold moonlight.",0,0,0,11,0,0
3140 DATA "Freedom","The night air hits your face.",0,0,0,0,0,0
