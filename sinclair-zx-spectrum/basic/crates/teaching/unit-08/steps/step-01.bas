10 GO SUB 7000: GO SUB 5000
15 LET room = 1
20 DIM g(8,8): LET moves = 0: LET won = 0: GO SUB 4000
21 IF e$ <> "" THEN GO TO 4500
85 GO SUB 6000
86 IF left = 0 THEN LET won = 1
100 GO SUB 1000
110 GO SUB 3000
120 IF k$ = "q" OR k$ = "Q" THEN GO TO 9000
130 IF k$ = "r" OR k$ = "R" THEN GO TO 20
140 IF won = 1 THEN GO TO 110
150 LET dr = 0: LET dc = 0
160 IF k$ = "i" OR k$ = "I" THEN LET dr = -1
170 IF k$ = "k" OR k$ = "K" THEN LET dr = 1
180 IF k$ = "j" OR k$ = "J" THEN LET dc = -1
190 IF k$ = "l" OR k$ = "L" THEN LET dc = 1
200 IF dr = 0 AND dc = 0 THEN GO TO 110
210 LET nr = pr + dr: LET nc = pc + dc
220 IF nr < 1 OR nr > 8 OR nc < 1 OR nc > 8 THEN GO TO 700
230 LET v = g(nr,nc)
240 IF v = 1 THEN GO TO 700
250 IF v = 3 OR v = 4 THEN GO TO 400
260 GO TO 500
400 LET br = nr + dr: LET bc = nc + dc
410 IF br < 1 OR br > 8 OR bc < 1 OR bc > 8 THEN GO TO 700
420 LET bv = g(br,bc)
430 IF bv <> 0 AND bv <> 2 THEN GO TO 700
440 LET g(nr,nc) = 0
450 IF v = 4 THEN LET g(nr,nc) = 2
460 LET g(br,bc) = 3
470 IF bv = 2 THEN LET g(br,bc) = 4
475 IF v = 4 THEN LET left = left + 1
476 IF bv = 2 THEN LET left = left - 1
480 LET r = br: LET c = bc: GO SUB 2000
500 LET oldr = pr: LET oldc = pc
510 LET pr = nr: LET pc = nc: LET moves = moves + 1
520 LET r = oldr: LET c = oldc: GO SUB 2000
530 LET r = pr: LET c = pc: GO SUB 2000
590 IF left = 0 THEN LET won = 1
600 GO SUB 2500
610 GO TO 110
700 GO TO 110
1000 BORDER 0: PAPER 0: INK 7: CLS
1010 PRINT AT 0, 2; INK 5; "CRATES"; AT 0, 24; INK 7; "ROOM 0"; room
1020 PRINT AT 20, 2; INK 7; "I up  J left  K down  L right"
1030 PRINT AT 21, 6; INK 5; "R restart     Q quit";
1040 FOR r = 1 TO 8: FOR c = 1 TO 8
1050 GO SUB 2000
1060 NEXT c: NEXT r
1070 GO SUB 2500
1080 RETURN
2000 LET y = 3 + 2 * (r - 1): LET x = 8 + 2 * (c - 1)
2010 LET z = g(r,c) + 1
2020 IF r = pr AND c = pc THEN LET z = 6
2025 IF z = 6 AND g(r,c) = 2 THEN LET z = 7
2030 PRINT AT y,x; INK a(z); t$(z,1 TO 2); AT y+1,x; t$(z,3 TO 4)
2040 RETURN
2500 PRINT AT 1, 2; INK 7; "STEPS "; moves; "    "
2505 PRINT AT 1, 18; INK 5; "GOALS "; total - left; "/"; total
2510 IF won = 1 THEN PRINT AT 19, 2; INK 4; "Delivered! R replay / Q quit"
2540 RETURN
3000 LET k$ = INKEY$
3010 IF k$ = h$ THEN GO TO 3000
3020 LET h$ = k$
3025 IF k$ = "" THEN GO TO 3000
3030 RETURN
4000 RESTORE 8000
4005 LET people = 0: LET crates = 0: LET goals = 0: LET e$ = ""
4010 FOR r = 1 TO 8: READ m$
4015 IF LEN m$ <> 8 THEN LET e$ = "Use eight symbols per row.": RETURN
4020 FOR c = 1 TO 8: LET b$ = m$(c): LET v = -1
4030 IF b$ = "-" THEN LET v = 0
4040 IF b$ = "#" THEN LET v = 1
4050 IF b$ = "." THEN LET v = 2
4060 IF b$ = "C" THEN LET v = 3
4070 IF b$ = "*" THEN LET v = 4
4080 IF b$ = "P" OR b$ = "+" THEN LET pr = r: LET pc = c: LET v = 0
4090 IF b$ = "+" THEN LET v = 2
4095 IF v = -1 THEN LET e$ = "Unknown map symbol.": RETURN
4100 LET g(r,c) = v
4102 IF b$ = "P" OR b$ = "+" THEN LET people = people + 1
4104 IF v = 3 OR v = 4 THEN LET crates = crates + 1
4106 IF v = 2 OR v = 4 THEN LET goals = goals + 1
4110 NEXT c: NEXT r
4120 IF people <> 1 THEN LET e$ = "Use exactly one player.": RETURN
4130 IF crates = 0 THEN LET e$ = "Add at least one crate.": RETURN
4140 IF crates <> goals THEN LET e$ = "Match crates and targets.": RETURN
4150 IF goals = 0 THEN LET e$ = "Add at least one target."
4160 RETURN
4500 BORDER 0: PAPER 0: INK 7: CLS
4510 PRINT AT 4,2; "Check room "; room
4520 PRINT AT 6,2; e$
4530 IF r < 9 THEN PRINT AT 8,2; "Row "; r
4540 PRINT AT 11,2; "Edit DATA, then RUN again."
4550 STOP
5000 BORDER 0: PAPER 0: INK 7: CLS: LET h$ = ""
5010 PRINT AT 2, 12; INK 5; "CRATES"
5020 PRINT AT 5, 2; INK 7; "A small warehouse puzzle."
5030 PRINT AT 7, 1; "I up, J left, K down, L right."
5040 PRINT AT 9, 1; "Push crates onto the targets."
5050 PRINT AT 11, 1; "You can push, but never pull."
5060 PRINT AT 13, 1; "R restarts the room. Q quits."
5070 PRINT AT 15, 1; "One step per press. Take time."
5080 PRINT AT 18, 1; "S starts. Q quits."
5090 GO SUB 3000
5100 IF k$ = "q" OR k$ = "Q" THEN GO TO 9000
5110 IF k$ <> "s" AND k$ <> "S" THEN GO TO 5090
5120 RETURN
6000 LET left = 0: LET total = 0: FOR r = 1 TO 8: FOR c = 1 TO 8
6010 IF g(r,c) = 2 THEN LET left = left + 1
6015 IF g(r,c) = 2 OR g(r,c) = 4 THEN LET total = total + 1
6020 NEXT c: NEXT r: RETURN
7000 RESTORE 7200: FOR n = 0 TO 159: READ b: POKE USR "a" + n,b: NEXT n
7010 DIM t$(7,4): DIM a(7)
7020 LET t$(1) = "    ": LET t$(2) = CHR$ 144 + CHR$ 145 + CHR$ 146 + CHR$ 147
7030 LET t$(3) = CHR$ 148 + CHR$ 149 + CHR$ 150 + CHR$ 151
7040 LET t$(4) = CHR$ 152 + CHR$ 153 + CHR$ 154 + CHR$ 155: LET t$(5) = t$(4)
7050 LET t$(6) = CHR$ 156 + CHR$ 157 + CHR$ 158 + CHR$ 159
7055 LET t$(7) = CHR$ 160 + CHR$ 161 + CHR$ 162 + CHR$ 163
7060 LET a(1) = 0: LET a(2) = 1: LET a(3) = 5: LET a(4) = 6: LET a(5) = 4: LET a(6) = 7: LET a(7) = 5: RETURN
7200 DATA 0,254,129,129,129,129,129,0
7210 DATA 0,254,2,2,2,2,2,0
7220 DATA 127,64,64,64,64,64,127,0
7230 DATA 127,129,129,129,129,129,127,0
7240 DATA 0,0,0,3,12,8,16,17
7250 DATA 0,0,0,192,48,16,8,136
7260 DATA 17,16,8,12,3,0,0,0
7270 DATA 136,8,16,48,192,0,0,0
7280 DATA 0,127,64,95,88,84,82,81
7290 DATA 0,254,2,250,26,42,74,138
7300 DATA 81,82,84,88,95,64,127,0
7310 DATA 138,74,42,26,250,2,254,0
7320 DATA 3,7,7,3,1,15,31,27
7330 DATA 192,224,224,192,128,240,248,216
7340 DATA 27,3,3,7,6,6,14,0
7350 DATA 216,192,192,224,96,96,112,0
7360 DATA 3,7,7,3,13,15,31,27
7370 DATA 192,224,224,192,176,240,248,216
7380 DATA 27,19,11,15,7,6,14,0
7390 DATA 216,200,208,240,224,96,112,0
8000 DATA "########"
8010 DATA "#------#"
8020 DATA "#--#.--#"
8030 DATA "#--#---#"
8040 DATA "#--C---#"
8050 DATA "#-P----#"
8060 DATA "#------#"
8070 DATA "########"
9000 PAPER 0: INK 7
9010 PRINT AT 21, 0; "Finished. RUN to try again.     ";
9020 STOP
