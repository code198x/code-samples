   5 BORDER 0: PAPER 0: INK 7: CLS
  10 LET t=9
  12 FOR c=t TO 0 STEP -1
  14 IF c>5 THEN LET pc=7
  16 IF c<=5 AND c>2 THEN LET pc=6
  18 IF c<=2 THEN LET pc=2
  20 LET dr=3: LET v=c: GO SUB 8200
  22 IF c>5 THEN BORDER 0
  24 IF c<=5 AND c>2 THEN BORDER 6
  26 IF c<=2 THEN BORDER 2
  28 BEEP 0.06,5+((t-c)*3)
  30 PAUSE 20
  32 NEXT c
  34 STOP
8200 REM === Draw single digit centred ===
8210 FOR r=dr TO dr+4
8220 PRINT AT r,12;"        "
8230 NEXT r
8240 LET dc=14: LET f=v: GO SUB 8000
8250 RETURN
8000 REM === Draw digit f at dr,dc ===
8010 RESTORE 5100+f*10
8020 FOR r=0 TO 4
8030 READ a$
8040 FOR q=1 TO LEN a$
8050 IF a$(q TO q)="1" THEN PRINT AT dr+r,dc+q-1; PAPER pc;" "
8060 NEXT q
8070 NEXT r
8080 RETURN
5100 DATA "1111","1..1","1..1","1..1","1111"
5110 DATA ".11.","..1.","..1.","..1.",".11."
5120 DATA "1111","...1","1111","1...","1111"
5130 DATA "1111","...1",".111","...1","1111"
5140 DATA "1..1","1..1","1111","...1","...1"
5150 DATA "1111","1...","1111","...1","1111"
5160 DATA "1111","1...","1111","1..1","1111"
5170 DATA "1111","...1","..1.",".1..",".1.."
5180 DATA "1111","1..1","1111","1..1","1111"
5190 DATA "1111","1..1","1111","...1","1111"
