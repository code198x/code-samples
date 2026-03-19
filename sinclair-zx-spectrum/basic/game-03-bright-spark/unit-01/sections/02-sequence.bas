 200 REM === Add to sequence ===
 210 LET p=INT (RND*4)+1
 220 LET p$="1"
 230 IF p=2 THEN LET p$="2"
 240 IF p=3 THEN LET p$="3"
 250 IF p=4 THEN LET p$="4"
 260 LET s$=s$+p$
 270 LET r=21: GO SUB 3100: LET t$="Watch... Round "+STR$ (LEN s$): INK 5: GO SUB 3000
 280 PAUSE 50
 300 REM === Play sequence ===
 310 FOR i=1 TO LEN s$
 320 IF s$(i)="1" THEN GO SUB 2100
 330 IF s$(i)="2" THEN GO SUB 2200
 340 IF s$(i)="3" THEN GO SUB 2300
 350 IF s$(i)="4" THEN GO SUB 2400
 360 PAUSE 15
 370 NEXT i
