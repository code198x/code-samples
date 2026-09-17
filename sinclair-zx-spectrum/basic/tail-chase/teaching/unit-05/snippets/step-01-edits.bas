100 DIM a(12): DIM b(12)
350 LET t = t + 1: IF t = 13 THEN LET t = 1
360 GO TO 390
390 LET h = h + 1: IF h = 13 THEN LET h = 1
3500 LET hit = 0: LET slot = t
3510 FOR j = 1 TO n
3520 IF j = 1 AND grow = 0 THEN GO TO 3540
3530 IF a(slot) = nr AND b(slot) = nx THEN LET hit = 1
3540 LET slot = slot + 1: IF slot = 13 THEN LET slot = 1
