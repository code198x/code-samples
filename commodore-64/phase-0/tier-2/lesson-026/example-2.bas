10 rem direction decoder
20 print chr$(147);chr$(18)
30 print "joystick direction decoder"
40 print chr$(146)
50 print
60 print "move joystick to see direction"
70 print
80 rem main loop
90 j=peek(56320) and 31
100 rem check for fire button
110 if (j and 16)=0 then print chr$(19);"fire!              ":goto 280
120 rem check all 8 directions
130 if (j and 1)=0 and (j and 4)=0 then print chr$(19);"up-left            ":goto 280
140 if (j and 1)=0 and (j and 8)=0 then print chr$(19);"up-right           ":goto 280
150 if (j and 2)=0 and (j and 4)=0 then print chr$(19);"down-left          ":goto 280
160 if (j and 2)=0 and (j and 8)=0 then print chr$(19);"down-right         ":goto 280
170 rem check cardinal directions
180 if (j and 1)=0 then print chr$(19);"up                 ":goto 280
190 if (j and 2)=0 then print chr$(19);"down               ":goto 280
200 if (j and 4)=0 then print chr$(19);"left               ":goto 280
210 if (j and 8)=0 then print chr$(19);"right              ":goto 280
220 rem no movement
230 print chr$(19);"centre             "
280 rem short delay
290 for d=1 to 10:next
300 goto 90
