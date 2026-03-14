10 CLS
20 DIM w$(30, 5)
30 DIM l(30)
40 FOR i = 1 TO 30
50 READ l(i), w$(i)
60 NEXT i
70 LET e = 0: LET m = 0: LET v = 1: LET c = 0
80 LET s = 25
90 REM active words: y() = row, wi() = word index
100 DIM y(2)
110 DIM q(2)
120 LET h = 1
130 REM spawn first word
140 LET q(1) = INT (RND * 20) + 1
150 LET y(1) = 2
160 LET p = 1: LET b$ = ""
170 LET a$ = w$(q(1))(1 TO l(q(1)))
180 REM game loop
190 LET t = 0
200 LET t = t + 1
210 IF t < s THEN GO TO 300
220 LET t = 0
230 REM move words down
240 FOR i = 1 TO h
250 IF y(i) > 1 THEN PRINT AT y(i), i * 10; "       "
260 LET y(i) = y(i) + 1
270 IF y(i) >= 19 THEN GO TO 500
280 PRINT AT y(i), i * 10; INK 6; w$(q(i))(1 TO l(q(i)))
290 NEXT i
300 REM check input
310 LET k$ = INKEY$
320 IF k$ = "" THEN GO TO 200
330 IF k$ <> a$(p TO p) THEN GO TO 200
340 LET b$ = b$ + k$
350 LET p = p + 1
360 PRINT AT 21, 0; INK 4; b$; "       "
370 IF p <= LEN a$ THEN GO TO 200
380 REM word complete
390 PRINT AT y(1), 10; "       "
400 LET e = e + 1: LET c = c + 1
410 BEEP 0.1, 15
420 LET q(1) = INT (RND * 20) + 1
430 LET y(1) = 2
440 LET p = 1: LET b$ = ""
450 LET a$ = w$(q(1))(1 TO l(q(1)))
460 PRINT AT 20, 0; "Type: "; INK 5; a$; "       "
470 GO SUB 700
480 GO TO 200
500 REM word missed
510 PRINT AT y(i) - 1, i * 10; INK 2; w$(q(i))(1 TO l(q(i)))
520 LET m = m + 1
530 BEEP 0.2, -5
540 PAUSE 15
550 PRINT AT y(i) - 1, i * 10; "       "
560 LET q(i) = INT (RND * 20) + 1
570 LET y(i) = 2
580 IF i = 1 THEN LET p = 1: LET b$ = "": LET a$ = w$(q(1))(1 TO l(q(1)))
590 PRINT AT 21, 0; "               "
600 IF m >= 3 THEN GO TO 650
610 GO SUB 700
620 GO TO 200
650 REM game over
660 CLS
670 PRINT AT 8, 9; INK 2; "GAME OVER"
680 PRINT AT 10, 8; "Score: "; e
690 STOP
700 REM === draw HUD ===
710 PRINT AT 0, 0; INK 7; "Score:"; e; " Lv:"; v; " Miss:"; m; "/3  "
720 PRINT AT 20, 0; "Type: "; INK 5; a$; "       "
730 RETURN
800 DATA 3,"cat",3,"dog",3,"run",3,"box",3,"red"
810 DATA 3,"sun",3,"hat",3,"cup",3,"pen",3,"fox"
820 DATA 3,"jam",3,"big",3,"top",3,"hop",3,"zip"
830 DATA 3,"van",3,"wet",3,"map",3,"dot",3,"log"
840 DATA 4,"bird",4,"fish",4,"lamp",4,"tree",4,"star"
850 DATA 4,"ball",4,"frog",4,"drum",4,"bell",4,"corn"
