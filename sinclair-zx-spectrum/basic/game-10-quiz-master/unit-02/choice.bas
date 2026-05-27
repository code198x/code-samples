  10 BORDER 0: PAPER 0: INK 7: CLS
 130 CLS
 190 READ q$,a$,b$,c$,d$
 210 PRINT q$
 220 PRINT "1. ";a$
 230 PRINT "2. ";b$
 240 PRINT "3. ";c$
 250 PRINT "4. ";d$
 260 INPUT "Answer (1-4): ";g
 280 IF g <> 2 THEN PRINT "The answer was 2"
 290 IF g = 2 THEN PRINT "Correct!"
 550 DATA 2,2,2,2,3,2,3,2
 610 DATA "How many legs does a spider have?","Six","Eight","Ten","Twelve"

9000 PRINT AT y, (32 - LEN a$) / 2; a$
9010 RETURN
