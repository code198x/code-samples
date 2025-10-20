10 rem lives counter with damage
20 print chr$(147):poke 53280,0:poke 53281,0
30 li=3:sc=0
40 rem draw lives label
50 for i=0 to 4:read d:poke 1024+i,d:poke 55296+i,10:next
60 data 12,9,22,5,19
70 rem draw lives counter
80 poke 1024+6,48+li:poke 55296+6,10
90 rem game loop
100 get k$:if k$="" then 100
110 if k$=" " then gosub 200
120 sc=sc+1:gosub 300
130 for i=1 to 50:next i
140 goto 100
200 rem take damage
210 li=li-1
220 if li<0 then li=0
230 poke 1024+6,48+li:poke 55296+6,10
240 if li=0 then gosub 400
250 return
300 rem display score
310 s=sc
320 for i=2 to 0 step -1
330 poke 1024+32+i,48+(s-int(s/10)*10)
340 s=int(s/10)
350 next
360 return
400 rem game over
410 for i=0 to 8:read d:poke 1064+i,d:poke 55336+i,2:next
420 data 7,1,13,5,32,15,22,5,18
430 for i=1 to 300:next i
440 end
