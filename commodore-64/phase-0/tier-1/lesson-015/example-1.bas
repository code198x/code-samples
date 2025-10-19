10 rem reading the jiffy clock
20 print chr$(147)
30 print "ti clock in jiffies:"
40 print
50 print "ti = ";ti
60 print
70 print "seconds = ";int(ti/60)
80 print "minutes = ";int(ti/3600)
90 print
100 print "press space to read again"
110 get a$:if a$<>" " then 110
120 goto 20
