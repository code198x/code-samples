10 print chr$(147);"color selector"
20 print
30 print "0=black   1=white   2=red"
40 print "3=cyan    4=purple  5=green"
50 print "6=blue    7=yellow  8=orange"
60 print "9=brown  10=lt red 11=dk grey"
70 print "12=grey  13=lt grn 14=lt blue"
80 print "15=lt grey"
90 print
100 input "border color";b
110 input "background color";bg
120 poke 53280,b
130 poke 53281,bg
140 print chr$(147);"your choice!"
150 end
