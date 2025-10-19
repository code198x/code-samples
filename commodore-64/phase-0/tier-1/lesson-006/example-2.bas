10 sc=0
20 for q=1 to 3
30 read qu$,an$
40 print qu$
50 input us$
60 if us$=an$ then print "correct!": sc=sc+1
70 if us$<>an$ then print "wrong. it's ";an$
80 print
90 next q
100 print "score: ";sc;"/3"
110 data "what is 2+2?","4"
120 data "capital of france?","paris"
130 data "bits in a byte?","8"
140 end
