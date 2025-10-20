10 rem envelope shaping demo
20 rem setup volume
30 poke 54296,15
40 rem visual feedback
50 print chr$(147);chr$(18)
60 print "adsr envelope demo"
70 print chr$(146)
80 rem fast attack, medium decay, half sustain, medium release
90 poke 54277,9:poke 54278,132
100 rem frequency for middle c
110 poke 54273,16:poke 54272,193
120 print
130 print "press 1-4 to hear different"
140 print "envelope shapes:"
150 print
160 print "1: pluck (fast decay)"
170 print "2: pad (slow attack)"
180 print "3: stab (no sustain)"
190 print "4: bell (medium all)"
200 rem main loop
210 get k$:if k$="" then 210
220 if k$="1" then gosub 500
230 if k$="2" then gosub 600
240 if k$="3" then gosub 700
250 if k$="4" then gosub 800
260 goto 210
500 rem pluck - fast attack, fast decay, low sustain, fast release
510 poke 54277,9:poke 54278,16
520 poke 54276,17
530 for t=1 to 30:next
540 poke 54276,16
550 return
600 rem pad - slow attack, slow decay, high sustain, slow release
610 poke 54277,51:poke 54278,249
620 poke 54276,17
630 for t=1 to 80:next
640 poke 54276,16
650 return
700 rem stab - fast attack, fast decay, zero sustain, fast release
710 poke 54277,9:poke 54278,0
720 poke 54276,17
730 for t=1 to 20:next
740 poke 54276,16
750 return
800 rem bell - medium attack, medium decay, medium sustain, medium release
810 poke 54277,34:poke 54278,132
820 poke 54276,17
830 for t=1 to 50:next
840 poke 54276,16
850 return
