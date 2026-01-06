jsr add_score           ; Award points
            inc streak              ; Increment streak
            lda streak
            cmp best_streak
            bcc +
            sta best_streak         ; New best!
+           lda #FLASH_TIME
            sta hit_flash           ; Green flash
