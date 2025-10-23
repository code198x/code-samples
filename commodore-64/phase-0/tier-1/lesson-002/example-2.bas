10 rem random quiz
20 print chr$(147);"maths master"
30 print
40 a=int(rnd(1)*10)+1
50 b=int(rnd(1)*10)+1
60 c=a+b
70 print "what is ";a;" + ";b;"?"
80 input ans
90 if ans=c then print chr$(30);"correct!":s=s+1:goto 110
100 print chr$(28);"wrong! it's ";c
110 print
120 print "score: ";s
130 for d=1 to 500:next d
140 goto 40
