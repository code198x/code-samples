  10 BORDER 0: PAPER 0: INK 7: CLS
  20 LET pr=0: GO SUB 6000
  30 IF s<>0 THEN PRINT "Vocabulary error ";s: STOP
  40 LET rm=1: LET un=0: DIM l(2): DIM c(2)
  50 LET l(1)=1: LET c(1)=1: LET l(2)=2: LET c(2)=2
  60 PRINT "THE LANTERN ROOM"'"A tiny parser demonstration."'"HELP lists the commands."
  70 GO SUB 1000
 100 INPUT "> "; LINE a$
 105 CLS : PRINT "THE LANTERN ROOM"
 110 GO SUB 5000
 120 IF s=1 THEN GO TO 100
 130 IF s<>0 THEN GO SUB 2000: GO TO 100
 135 IF v>10 THEN PRINT "No action wired for ID ";v: GO TO 100
 140 IF v=1 THEN GO SUB 1000
 150 IF v=2 THEN GO SUB 1200
 160 IF v=3 THEN GO SUB 1400
 170 IF v=4 THEN GO SUB 1500
 180 IF v=5 THEN GO SUB 1600
 190 IF v=6 THEN GO SUB 1700
 200 IF v=7 THEN PRINT "Goodbye.": STOP
 210 IF v=8 THEN PRINT "LOOK, GO NORTH/SOUTH, TAKE name,"'"DROP name, INVENTORY, EXAMINE name"'"SEARCH [name], WAIT, QUIT."
 220 IF v=9 THEN PRINT "You wait. Nothing changes."
 230 IF v=10 THEN GO SUB 1800
 240 GO TO 100
1000 IF rm=1 THEN PRINT '"You are in a small store room."'"A passage leads north."
1010 IF rm=2 THEN PRINT '"A narrow hall. A door"'"stands north; the store is south."
1015 IF rm=2 AND un=0 THEN PRINT "The door is locked."
1020 IF rm=3 THEN PRINT '"You stand in an open courtyard."'"The hall is south."
1030 FOR j=1 TO 2
1040 IF l(j)=rm THEN PRINT "You can see a ";: GO SUB 1900: PRINT "."
1050 NEXT j
1060 RETURN
1200 IF n<>3 AND n<>4 THEN PRINT "Choose NORTH or SOUTH.": RETURN
1210 IF n=4 AND rm=1 THEN PRINT "There is no way south.": RETURN
1220 IF n=3 AND rm=3 THEN PRINT "There is no way north.": RETURN
1230 IF n<>3 OR rm<>2 OR un=1 THEN GO TO 1260
1232 LET ky=0
1234 FOR j=1 TO 2
1236 IF c(j)=2 AND l(j)=0 THEN LET ky=1
1238 NEXT j
1240 IF ky=0 THEN PRINT "The door is locked. Find a key.": RETURN
1250 LET un=1: PRINT "Your key opens the door."
1260 IF n=3 THEN LET rm=rm+1: GO SUB 1000: RETURN
1270 LET rm=rm-1: GO SUB 1000: RETURN
1400 GO SUB 4000: IF ob=0 THEN RETURN
1410 IF l(ob)=0 THEN PRINT "You are already carrying it.": RETURN
1420 LET l(ob)=0: PRINT "Taken.": RETURN
1500 GO SUB 4000: IF ob=0 THEN RETURN
1510 IF l(ob)<>0 THEN PRINT "You are not carrying it.": RETURN
1520 LET l(ob)=rm: PRINT "Dropped.": RETURN
1600 LET ct=0: PRINT "You are carrying:"
1610 FOR j=1 TO 2
1620 IF l(j)=0 THEN GO SUB 1900: PRINT : LET ct=ct+1
1630 NEXT j
1640 IF ct=0 THEN PRINT "Nothing."
1650 RETURN
1700 IF n=5 AND rm=2 THEN PRINT "A key should fit this lock.": RETURN
1710 GO SUB 4000: IF ob=0 THEN RETURN
1720 IF c(ob)=1 THEN PRINT "A sturdy lamp. It has no switch."
1730 IF c(ob)=2 THEN PRINT "A small brass key."
1740 RETURN
1800 IF n=0 THEN PRINT "Nothing is hidden here.": RETURN
1810 GO SUB 1700: RETURN
1900 IF c(j)=1 THEN PRINT "lamp";: RETURN
1910 IF c(j)=2 THEN PRINT "small key";: RETURN
1920 PRINT "object";: RETURN
2000 IF s=2 THEN PRINT "Please use at most63characters."
2010 IF s=3 THEN PRINT "Use letters, digits and spaces."
2020 IF s=4 THEN PRINT "Try one or two words."
2030 IF s=5 THEN PRINT "I do not know the verb ";w$
2040 IF s=6 THEN PRINT "I do not know the noun ";o$
2050 IF s=7 THEN PRINT w$;" what?"
2060 IF s=8 THEN PRINT w$;" does not take a noun."
2070 IF s=9 THEN PRINT "Parser is not initialised."
2080 RETURN
4000 REM Resolve a noun concept among nearby/carried objects
4010 LET ob=0: LET ct=0
4020 FOR j=1 TO 2
4030 IF c(j)=n AND (l(j)=rm OR l(j)=0) THEN LET ob=j: LET ct=ct+1
4040 NEXT j
4050 IF ct=0 THEN PRINT "You cannot see that here.": RETURN
4060 IF ct>1 THEN LET ob=0: PRINT "Two match; this demo cannot choose."
4070 RETURN
