10 rem box designer
20 print chr$(147);chr$(5)
30 print "box designer"
40 print
50 print "use i/j/k/m to move"
60 print "space to draw"
70 print "c to clear"
80 print "q to quit"
90 print
100 x=20:y=12
110 get k$:if k$="" then 110
120 if k$="i" then y=y-1
130 if k$="m" then y=y+1
140 if k$="j" then x=x-1
150 if k$="k" then x=x+1
160 if x<0 then x=0
170 if x>39 then x=39
180 if y<0 then y=0
190 if y>24 then y=24
200 if k$=" " then poke 1024+(y*40)+x,160
210 if k$="c" then for i=0 to 999:poke 1024+i,32:next i
220 if k$="q" then end
230 goto 110
