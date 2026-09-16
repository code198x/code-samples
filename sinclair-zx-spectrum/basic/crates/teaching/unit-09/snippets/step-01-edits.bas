135 IF won = 1 AND (k$ = "n" OR k$ = "N") THEN GO TO 800
800 LET room = room + 1
810 IF room = 3 THEN LET room = 1
820 GO TO 20
2510 IF won = 1 AND room = 1 THEN PRINT AT 19, 2; INK 4; "Delivered! N for next room"
2520 IF won = 1 AND room = 2 THEN PRINT AT 19, 2; INK 4; "Both done! N for a new game"
4002 IF room = 2 THEN RESTORE 8100
5020 PRINT AT 5, 2; INK 7; "Two rooms. Think, then push."
8100 DATA "########"
8110 DATA "#------#"
8120 DATA "#---.#-#"
8130 DATA "#---##-#"
8140 DATA "#---C-##"
8150 DATA "#---P--#"
8160 DATA "#------#"
8170 DATA "########"
