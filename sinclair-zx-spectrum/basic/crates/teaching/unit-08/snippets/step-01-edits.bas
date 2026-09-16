21 IF e$ <> "" THEN GO TO 4500
4005 LET people = 0: LET crates = 0: LET goals = 0: LET e$ = ""
4015 IF LEN m$ <> 8 THEN LET e$ = "Use eight symbols per row.": RETURN
4095 IF v = -1 THEN LET e$ = "Unknown map symbol.": RETURN
4102 IF b$ = "P" OR b$ = "+" THEN LET people = people + 1
4104 IF v = 3 OR v = 4 THEN LET crates = crates + 1
4106 IF v = 2 OR v = 4 THEN LET goals = goals + 1
4110 NEXT c: NEXT r
4120 IF people <> 1 THEN LET e$ = "Use exactly one player.": RETURN
4130 IF crates = 0 THEN LET e$ = "Add at least one crate.": RETURN
4140 IF crates <> goals THEN LET e$ = "Match crates and targets.": RETURN
4150 IF goals = 0 THEN LET e$ = "Add at least one target."
4160 RETURN
4500 BORDER 0: PAPER 0: INK 7: CLS
4510 PRINT AT 4,2; "Check room "; room
4520 PRINT AT 6,2; e$
4530 IF r < 9 THEN PRINT AT 8,2; "Row "; r
4540 PRINT AT 11,2; "Edit DATA, then RUN again."
4550 STOP
