20 PRINT AT 3,10; INK 6; BRIGHT 1; "YEARFALL"
30 PRINT AT 6,1; "One settlement. Keep it alive."
35 PRINT AT 7,2; "Review every ten years."
40 PRINT AT 8,2; "Feed people. Plant a harvest."
50 PRINT AT 9,2; "Keep grain for a poor year."
60 PRINT AT 11,2; "Each person needs 3 grain."
70 PRINT AT 12,2; "Each worker farms 2 acres."
80 PRINT AT 13,2; "Each acre costs 1 seed grain."
90 PRINT AT 15,2; "Harvest: 2 to 5 per acre."
95 PRINT AT 16,2; "Full food: 5% newcomers."
100 PRINT AT 18,2; "S starts. Q quits."
110 GO SUB 8000
120 IF k$="q" OR k$="Q" THEN STOP
130 IF k$<>"s" AND k$<>"S" THEN GO TO 110
