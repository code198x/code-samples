   1 REM Lucky Number v3
   5 BORDER 0: PAPER 0: INK 7: CLS
  10 REM === Rainbow cascade ===
  20 FOR i=0 TO 7
  30 FOR j=0 TO 31
  40 PRINT AT i,j; PAPER i;" "
  50 NEXT j
  55 BEEP 0.01,i*4+20
  60 NEXT i
  70 REM === Big LUCKY ===
  80 RESTORE 5000
  90 FOR r=0 TO 4
 100 READ a$
 110 FOR q=1 TO LEN a$
 120 IF a$(q)="1" THEN PRINT AT 9+r,q; PAPER 6;" "
 130 NEXT q
 140 NEXT r
 150 REM === Big NUMBER ===
 160 RESTORE 5010
 170 FOR r=0 TO 4
 180 READ a$
 190 FOR q=1 TO LEN a$
 200 IF a$(q)="1" THEN PRINT AT 15+r,q; PAPER 5;" "
 210 NEXT q
 220 NEXT r
 230 PRINT AT 21,6; INK 7; FLASH 1;" Press any key "; FLASH 0
 240 IF INKEY$="" THEN GO TO 240
5000 REM === LUCKY (5 wide, 1 gap) ===
5001 DATA "1.....1...1.11111.1...1.1...1"
5002 DATA "1.....1...1.1.....1..1...1.1."
5003 DATA "1.....1...1.1.....111.....1.."
5004 DATA "1.....1...1.1.....1..1....1.."
5005 DATA "11111.11111.11111.1...1...1.."
5010 REM === NUMBER (4 wide, 1 gap) ===
5011 DATA "1..1.1..1.1..1.111..1111.111."
5012 DATA "11.1.1..1.1111.1..1.1....1..1"
5013 DATA "1.11.1..1.1111.111..111..111."
5014 DATA "1..1.1..1.1..1.1..1.1....1.1."
5015 DATA "1..1.1111.1..1.111..1111.1..1"
