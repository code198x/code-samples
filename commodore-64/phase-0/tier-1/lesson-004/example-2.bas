10 rem array quiz
20 dim q$(4),an(4)
30 q$(0)="what is 2+2?":an(0)=4
40 q$(1)="what is 5*3?":an(1)=15
50 q$(2)="what is 10-3?":an(2)=7
60 q$(3)="what is 8/2?":an(3)=4
70 q$(4)="what is 6+7?":an(4)=13
80 print chr$(147);"quiz master"
90 print
100 for i=0 to 4
110 print q$(i)
120 input a
130 if a=an(i) then print "correct!":s=s+1:goto 150
140 print "wrong! it's";an(i)
150 print
160 next i
170 print "final score:";s;"out of 5"
180 print
190 print "play again? (y/n)"
200 get k$:if k$="" then 200
210 if k$="y" then s=0:run
