10 poke 53280,0
20 poke 53281,0
30 print chr$(147);"black screen"
40 for i=1 to 2000:next i
50 poke 53280,6
60 poke 53281,14
70 print chr$(147);"blue screen"
80 end
