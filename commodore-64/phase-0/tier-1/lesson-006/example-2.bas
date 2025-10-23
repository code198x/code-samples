10 rem quiz master pro
20 print chr$(147);"quiz master pro"
30 print
40 s=0
50 for i=1 to 5
60 read q$,a
70 print q$
80 input r
90 if r=a then print "correct!":s=s+1:goto 110
100 print "wrong! it's";a
110 print
120 next i
130 print "final score:";s;"out of 5"
140 print
150 print "play again? (y/n)"
160 get k$:if k$="" then 160
170 if k$="y" then restore:run
180 data what is 2+2?,4
190 data what is 5*3?,15
200 data what is 10-3?,7
210 data what is 8/2?,4
220 data what is 6+7?,13
