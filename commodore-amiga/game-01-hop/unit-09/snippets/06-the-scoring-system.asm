handle_movement:
            ; ... edge detection code ...

            btst    #3,d1               ; Up pressed?
            beq.s   .no_up
            move.w  frog_y,d0
            sub.w   #HOP_DISTANCE,d0
            cmp.w   #48,d0
            blt.s   .no_up
            move.w  d0,frog_y
            clr.w   on_log

            ; Award points for forward progress
            add.l   #SCORE_HOP,score

.no_up:
            ; ... rest of movement code ...
