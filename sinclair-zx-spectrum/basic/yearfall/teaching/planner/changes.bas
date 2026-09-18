220 LET feed=3*pop
230 IF feed>grain THEN LET feed=grain
240 LET plant=land
250 IF plant>2*INT (feed/3) THEN LET plant=2*INT (feed/3)
260 IF plant>grain-feed THEN LET plant=grain-feed
350 IF k$="p" OR k$="P" THEN LET edit=3: GO SUB 6000: GO TO 270
2230 PRINT AT 19,1; INK 5; "F/P edit food and planting."
6020 IF edit=3 THEN LET a$="Plant acres"
6230 IF edit=3 THEN LET plant=value
