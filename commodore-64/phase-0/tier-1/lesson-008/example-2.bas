10 print chr$(147)
20 for r=0 to 24
30 for c=0 to 39
40 sc=1024+(r*40)+c
50 poke sc,160
60 poke 55296+(r*40)+c,1+(r and 7)
70 next c
80 next r
90 end
