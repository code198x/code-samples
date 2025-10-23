10 rem box designer demo
20 print chr$(147);chr$(5)
30 print "box designer"
40 print
50 print "use i/j/k/m to move"
60 print "space to draw"
70 print "c to clear"
80 print "q to quit"
90 print
100 x=10:y=10
110 for i=0 to 20
120 poke 1024+(10*40)+10+i,64
130 poke 1024+(20*40)+10+i,64
140 next i
150 for i=0 to 10
160 poke 1024+((10+i)*40)+10,66
170 poke 1024+((10+i)*40)+30,66
180 next i
190 get k$:if k$="" then 190
200 if k$="i" then y=y-1
210 if k$="m" then y=y+1
220 if k$="j" then x=x-1
230 if k$="k" then x=x+1
240 if x<0 then x=0
250 if x>39 then x=39
260 if y<0 then y=0
270 if y>24 then y=24
280 if k$=" " then poke 1024+(y*40)+x,160
290 if k$="c" then for i=0 to 999:poke 1024+i,32:next i
300 if k$="q" then end
310 goto 190
