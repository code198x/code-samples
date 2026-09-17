440 IF eaten = 1 THEN LET e$ = "One snack. Nicely done!": GO TO 4000
1020 PRINT AT 2,5; INK 7; "Eat one snack. R retries."
2000 LET fr = 1 + INT (RND * 16): LET fc = 1 + INT (RND * 24)
2010 IF g(fr,fc) = 1 THEN GO TO 2000
