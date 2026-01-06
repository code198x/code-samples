; In check_home, after filling a slot:
            ; Award time bonus
            move.w  timer_value,d0
            lsr.w   #4,d0           ; Divide by 16 for reasonable bonus
            ext.l   d0
            add.l   d0,score

            ; Reset timer for next attempt
            bsr     reset_timer
