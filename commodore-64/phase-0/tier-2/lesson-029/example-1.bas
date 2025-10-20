10 rem score display at top of screen
20 print chr$(147):poke 53280,0:poke 53281,0
30 sc=0
40 rem draw score label
50 for i=0 to 4:read d:poke 1024+i,d:poke 55296+i,1:next
60 data 19,3,15,18,5
70 rem game loop
80 sc=sc+1
90 gosub 200
100 for i=1 to 30:next i
110 if sc<999 then 80
120 end
200 rem display score subroutine
210 s=sc
220 for i=2 to 0 step -1
230 poke 1024+6+i,48+(s-int(s/10)*10)
240 s=int(s/10)
250 next
260 return
