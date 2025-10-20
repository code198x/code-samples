10 rem joystick tester
20 print chr$(147);chr$(18)
30 print "joystick port 2 tester"
40 print chr$(146)
50 print
60 print "     up"
70 print "left   right"
80 print "    down"
90 print
100 print "fire:"
110 rem main loop
120 j=peek(56320) and 31
130 rem display up
140 print chr$(19);chr$(145);chr$(145);chr$(145);chr$(145);chr$(145)
150 if (j and 1)=0 then print "  *";chr$(157);chr$(157);chr$(157):goto 160
155 print "   "
160 rem display left and right
170 print chr$(145)
180 if (j and 4)=0 then print "*":goto 190
185 print " "
190 print "     ";
200 if (j and 8)=0 then print "*":goto 210
205 print " "
210 rem display down
220 print chr$(145);chr$(145);chr$(157);chr$(157);chr$(157);chr$(157)
230 if (j and 2)=0 then print "  *":goto 240
235 print "   "
240 rem display fire
250 print chr$(145);chr$(145);chr$(145);chr$(145)
260 if (j and 16)=0 then print "pressed":goto 270
265 print "       "
270 rem short delay
280 for d=1 to 10:next
290 goto 120
