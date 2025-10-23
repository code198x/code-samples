10 rem rainbow border
20 c=0
30 poke 53280,c
40 c=c+1
50 if c>15 then c=0
60 for d=1 to 50:next d
70 goto 30
