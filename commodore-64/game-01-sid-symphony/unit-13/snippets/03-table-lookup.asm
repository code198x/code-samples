update_speed:
            ldx multiplier
            dex                     ; Convert 1-4 to 0-3 index
            lda speed_table,x
            sta current_speed
            rts
