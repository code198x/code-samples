5 REM === THE CURSED MANOR ===
10 BORDER 0: PAPER 0: INK 7: CLS
14 DIM r$(20,20): DIM d$(20,60)
16 DIM e(20,6): DIM z(20)
18 DIM w(20): DIM s$(10,15): DIM c$(11,40)
20 DIM q(10): DIM g$(5,15): DIM u(5)
22 DIM o(5): DIM p(5)
24 LET r = 1: LET t = 0: LET v = 0
26 REM r=room, t=turns, v=score
28 REM flags: a=key, b=tower, d=chamber, f=candle, h=name, j=curse
30 LET a = 0: LET b = 0: LET d = 0: LET f = 0: LET h = 0: LET j = 0
32 GO SUB 3000
34 CLS: GO SUB 700
36 REM === main loop ===
38 PRINT AT 20, 0; INK 7; "> ";
40 INPUT LINE i$
42 IF i$ = "" THEN GO TO 36
44 LET t = t + 1
46 GO SUB 200
48 GO SUB 900
50 GO TO 36
200 REM === parser ===
202 LET n = 0
204 FOR i = 1 TO LEN i$
206 IF i$(i) = " " THEN LET n = i: LET i = LEN i$
208 NEXT i
210 IF n = 0 THEN LET x$ = i$: LET y$ = ""
212 IF n > 0 THEN LET x$ = i$(1 TO n - 1): LET y$ = i$(n + 1 TO )
234 REM uppercase verb
236 FOR i = 1 TO LEN x$
238 LET n = CODE x$(i): IF n >= 97 AND n <= 122 THEN LET x$(i) = CHR$ (n - 32)
240 NEXT i
242 FOR i = 1 TO LEN y$
244 LET n = CODE y$(i): IF n >= 97 AND n <= 122 THEN LET y$(i) = CHR$ (n - 32)
246 NEXT i
248 REM synonyms
250 IF x$ = "TAKE" OR x$ = "GRAB" THEN LET x$ = "GET"
252 IF x$ = "CHECK" OR x$ = "INSPECT" THEN LET x$ = "EXAMINE"
254 IF x$ = "WALK" OR x$ = "MOVE" THEN LET x$ = "GO"
256 IF x$ = "UNLOCK" THEN LET x$ = "USE"
258 REM dispatch
260 IF x$ = "GO" THEN GO SUB 300: RETURN
262 IF x$ = "LOOK" THEN CLS: GO SUB 700: RETURN
264 IF x$ = "GET" THEN GO SUB 350: RETURN
266 IF x$ = "DROP" THEN GO SUB 380: RETURN
268 IF x$ = "EXAMINE" THEN GO SUB 400: RETURN
270 IF x$ = "USE" THEN GO SUB 450: RETURN
272 IF x$ = "INVENTORY" THEN GO SUB 500: RETURN
274 IF x$ = "SAY" THEN GO SUB 550: RETURN
276 IF x$ = "LIGHT" THEN GO SUB 580: RETURN
280 IF x$ = "SCORE" THEN PRINT AT 18, 0; INK 6; "Score: "; v: RETURN
282 IF x$ = "HELP" THEN PRINT AT 14, 0; INK 5; "GO GET DROP EXAMINE USE": PRINT AT 15, 0; INK 5; "LOOK INVENTORY SCORE HELP": RETURN
284 IF x$ = "QUIT" THEN PRINT AT 18, 0; INK 7; "Final score: "; v: STOP
286 PRINT AT 18, 0; INK 2; "I do not understand that."
288 RETURN
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
352 FOR i = 1 TO 6
354 IF y$ = s$(i) AND q(i) = r THEN LET q(i) = -1: PRINT AT 18, 0; INK 4; "Taken.": BEEP 0.02, 10: RETURN
356 NEXT i
358 PRINT AT 18, 0; INK 2; "I cannot see that here."
360 RETURN
380 REM === drop item ===
382 FOR i = 1 TO 6
384 IF y$ = s$(i) AND q(i) = -1 THEN LET q(i) = r: PRINT AT 18, 0; INK 4; "Dropped.": RETURN
386 NEXT i
388 PRINT AT 18, 0; INK 2; "You are not carrying that."
390 RETURN
400 REM === examine ===
402 REM check items in room or inventory
404 FOR i = 1 TO 6
406 IF y$ = s$(i) AND (q(i) = r OR q(i) = -1) THEN PRINT AT 14, 0; INK 6; c$(i): BEEP 0.02, 12: RETURN
408 NEXT i
410 REM check guests
412 FOR i = 1 TO 5
414 IF o(i) = r AND p(i) = 1 THEN GO TO 420
416 GO TO 430
420 IF y$ = g$(i) OR y$ = "GUEST" THEN PRINT AT 14, 0; INK 6; c$(i + 6): LET v = v + 2: BEEP 0.05, 15: RETURN
430 NEXT i
432 PRINT AT 18, 0; INK 2; "I cannot see that here."
434 RETURN
450 REM === use item ===
452 IF y$ = "KEY" AND q(1) = -1 AND r = 8 THEN LET b = 1: LET e(8,5) = 17: LET a = 1: PRINT AT 14, 0; INK 4; BRIGHT 1; "The tower door unlocks!": LET u(4) = 0: LET v = v + 3: BEEP 0.1, 10: BEEP 0.1, 15: RETURN
456 PRINT AT 18, 0; INK 2; "Nothing happens."
458 RETURN
500 REM === inventory ===
502 LET n = 0
504 PRINT AT 14, 0; INK 7; "You are carrying:"
506 FOR i = 1 TO 6
508 IF q(i) = -1 THEN PRINT AT 15 + n, 2; INK 5; s$(i): LET n = n + 1
510 NEXT i
512 IF n = 0 THEN PRINT AT 15, 2; INK 5; "Nothing."
514 RETURN
550 REM === say ===
552 IF y$ = "THORNBURY" AND h = 0 THEN LET h = 1: PRINT AT 14, 0; INK 4; BRIGHT 1; "The name echoes through the manor!": LET u(1) = 0: LET u(2) = 0: LET v = v + 5: BEEP 0.1, 12: BEEP 0.1, 16: RETURN
554 PRINT AT 18, 0; INK 7; "The word echoes and fades."
556 RETURN
580 REM === light ===
582 IF y$ = "CANDLE" AND q(2) = -1 AND q(3) = -1 AND f = 0 THEN LET f = 1: PRINT AT 14, 0; INK 5; BRIGHT 1; "The candle burns with cold blue fire!": LET u(3) = 0: LET u(5) = 0: LET v = v + 3: BEEP 0.1, 10: RETURN
584 IF y$ = "CANDLE" AND q(3) <> -1 THEN PRINT AT 18, 0; INK 2; "You need something to light it with.": RETURN
586 PRINT AT 18, 0; INK 2; "You cannot light that."
588 RETURN
700 REM === display room ===
702 PRINT AT 0, 0; INK 7; BRIGHT 1; r$(r)
704 PRINT AT 2, 0; INK 5; d$(r)
706 REM show items
708 FOR i = 1 TO 6
710 IF q(i) = r THEN PRINT AT 6, 0; INK 6; "There is a "; s$(i); " here."
712 NEXT i
714 REM show guests
716 FOR i = 1 TO 5
718 IF o(i) = r AND p(i) = 1 THEN PRINT AT 8, 0; INK 3; g$(i); " stands frozen here."
720 IF o(i) = r AND p(i) = 0 THEN PRINT AT 8, 0; INK 4; g$(i); " is here."
722 NEXT i
724 REM show exits
726 PRINT AT 10, 0; INK 7; "Exits: ";
728 IF e(r,1) <> 0 THEN PRINT "N ";
730 IF e(r,2) <> 0 THEN PRINT "S ";
732 IF e(r,3) <> 0 THEN PRINT "E ";
734 IF e(r,4) <> 0 THEN PRINT "W ";
736 IF e(r,5) <> 0 THEN PRINT "U ";
738 IF e(r,6) <> 0 THEN PRINT "D ";
740 PRINT
742 RETURN
900 REM === NPC turn ===
902 FOR i = 1 TO 5
904 IF p(i) = 1 THEN GO TO 930
906 IF u(i) <> 0 THEN GO TO 930
930 IF u(i) > 0 THEN LET u(i) = u(i) - 1
932 NEXT i
934 RETURN
3000 REM === load data ===
3002 RESTORE 3100
3004 FOR i = 1 TO 20
3006 READ r$(i), d$(i)
3008 READ e(i,1), e(i,2), e(i,3), e(i,4), e(i,5), e(i,6)
3010 NEXT i
3012 RESTORE 3500
3014 FOR i = 1 TO 6
3016 READ s$(i), c$(i), q(i)
3018 NEXT i
3020 RESTORE 3600
3022 FOR i = 1 TO 5
3024 READ g$(i), o(i), p(i)
3026 NEXT i
3028 REM guest clues stored in c$(7-11)
3030 RESTORE 3700
3032 FOR i = 7 TO 11
3034 READ c$(i)
3036 NEXT i
3038 LET w(1) = 1
3040 RETURN
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
3500 REM === ITEM DATA ===
3502 DATA "KEY","A small silver key, cold to the touch.",6
3504 DATA "CANDLE","A blue candle from the altar.",16
3506 DATA "TINDERBOX","A brass tinderbox from the desk.",10
3508 DATA "AMULET","The Eye of Thornbury, dark and heavy.",15
3510 DATA "NOTE","A folded note in faded ink.",0
3512 DATA "ROPE","A coil of rough rope.",19
3600 REM === GUEST DATA ===
3602 DATA "COLONEL",11,1
3604 DATA "HARLAN",5,1
3606 DATA "PEMBURY",2,1
3608 DATA "IVY",4,1
3610 DATA "WHITMORE",1,1
3700 REM === GUEST CLUES ===
3702 DATA "Chalk marks on the baize spell THORN."
3704 DATA "The open page describes a binding ritual."
3706 DATA "Her brooch is an eye motif. She mutters BURY."
3708 DATA "A note in her apron: Beware the name."
3710 DATA "His bible is open to a marked passage."
