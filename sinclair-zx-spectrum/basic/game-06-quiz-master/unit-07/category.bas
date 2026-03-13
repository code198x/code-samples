10 CLS
20 PRINT "Pick a category:"
30 PRINT
40 PRINT "  1. Science"
50 PRINT "  2. Geography"
60 PRINT "  3. History"
70 PRINT
80 INPUT "Category (1-3)? "; k
90 IF k < 1 OR k > 3 THEN GO TO 80
100 IF k = 1 THEN RESTORE 500
110 IF k = 2 THEN RESTORE 600
120 IF k = 3 THEN RESTORE 700
130 LET n = 0
140 FOR i = 1 TO 3
150 READ q$, a$, b$, c$, r
160 CLS
170 IF k = 1 THEN INK 4: PRINT "Science": INK 0
180 IF k = 2 THEN INK 1: PRINT "Geography": INK 0
190 IF k = 3 THEN INK 2: PRINT "History": INK 0
200 PRINT
210 PRINT q$
220 PRINT
230 PRINT "  1. "; a$
240 PRINT "  2. "; b$
250 PRINT "  3. "; c$
260 PRINT
270 INPUT "Your answer (1-3)? "; g
280 IF g = r THEN INK 4: PRINT "Correct!": INK 0: LET n = n + 1: BEEP 0.2, 12
290 IF g <> r THEN INK 2: PRINT "Wrong!": INK 0: BEEP 0.3, -5
300 PAUSE 50
310 NEXT i
320 CLS
330 PRINT "Score: "; n; " out of 3"
500 DATA "What gas do plants breathe in?","Oxygen","Nitrogen","Carbon dioxide",3
510 DATA "How many bones in the body?","106","206","306",2
520 DATA "What planet has rings?","Mars","Saturn","Jupiter",2
600 DATA "What is the longest river?","Amazon","Nile","Thames",2
610 DATA "Which continent is biggest?","Africa","Europe","Asia",3
620 DATA "What ocean is the largest?","Atlantic","Indian","Pacific",3
700 DATA "When did WW2 end?","1943","1945","1947",2
710 DATA "Who built the pyramids?","Romans","Greeks","Egyptians",3
720 DATA "When was the Moon landing?","1959","1969","1979",2
