810 IF room = 4 THEN LET room = 1
2510 IF won = 1 AND room < 3 THEN PRINT AT 19, 2; INK 4; "Delivered! N for next room"
2520 IF won = 1 AND room = 3 THEN PRINT AT 19, 2; INK 4; "All done! N for a new game"
4003 IF room = 3 THEN RESTORE 8200
5020 PRINT AT 5, 2; INK 7; "Three rooms. Think, then push."
8200 DATA "########"
8210 DATA "###.####"
8220 DATA "###.####"
8230 DATA "#--C---#"
8240 DATA "#--C---#"
8250 DATA "#--P---#"
8260 DATA "#------#"
8270 DATA "########"
