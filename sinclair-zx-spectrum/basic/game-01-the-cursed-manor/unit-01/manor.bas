10 BORDER 0: PAPER 0: INK 7: CLS
15 PRINT AT 4,6;"Code Like It's 198x"
17 PRINT AT 6,12; INK 5;"Game #1"
20 PRINT AT 9,8; INK 6;"THE CURSED MANOR"
30 PRINT AT 11,3; INK 5;"A Sinclair BASIC Adventure"
40 PRINT AT 17,5;"Press any key to begin"
50 BEEP 0.5,0: BEEP 0.3,-5: BEEP 0.8,-12
60 IF INKEY$="" THEN GO TO 60
70 CLS
80 PRINT INK 5;"ENTRANCE HALL"
90 PRINT
100 PRINT "You arrive at Thornbury Manor"
110 PRINT "as the last light fades."
120 PRINT
130 PRINT "The front door swings open at"
140 PRINT "your touch. Inside, a grand"
150 PRINT "hallway stretches before you."
160 PRINT
170 PRINT "Every guest stands frozen."
180 PRINT "A man reaching for a glass."
190 PRINT "A woman mid-laugh."
200 PRINT "None of them move."
210 PRINT
220 PRINT INK 2;"The front door locks behind"
230 PRINT INK 2;"you."
240 BEEP 0.5,-10
