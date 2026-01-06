inc streak              ; One more in a row
            lda streak
            cmp best_streak         ; New record?
            bcc +                   ; No, skip
            sta best_streak         ; Yes, save it
+
