  50 LET w$="1"
  60 IF w=2 THEN LET w$="2"
  70 IF w=3 THEN LET w$="3"
  80 IF w=4 THEN LET w$="4"
 650 LET k$=INKEY$
 810 IF k$=w$ THEN GO TO 1000
