10 rem simple three-state game
20 rem state: 0=title, 1=play, 2=gameover
30 gs=0
35 sc=0:hi=0
40 rem main loop
50 on gs+1 gosub 100,200,400
60 goto 50
100 rem title screen
110 print chr$(147)
120 poke 53280,6:poke 53281,6
130 restore:for i=0 to 9:read d:poke 1104+i,d:poke 55376+i,14:next
140 data 16,18,5,19,19,32,6,9,18,5
150 for i=1 to 100:next i
160 get k$:if k$<>"" then gs=1:sc=0
170 return
200 rem play state
210 if sc=0 then print chr$(147):poke 53280,0:poke 53281,0
220 sc=sc+1
230 for i=4 to 0 step -1
240 s=sc:poke 1024+i,48+(s-int(s/10)*10):s=int(s/10)
250 next
260 if sc>=500 then gs=2
270 for i=1 to 3:next i
280 return
400 rem game over state
410 poke 53280,2:poke 53281,2
420 restore 430:for i=0 to 8:read d:poke 1144+i,d:poke 55416+i,7:next
430 data 7,1,13,5,32,15,22,5,18
440 if sc>hi then hi=sc
450 for i=1 to 200:next i
460 gs=0
470 return
