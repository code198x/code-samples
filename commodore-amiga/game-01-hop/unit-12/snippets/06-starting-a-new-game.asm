start_new_game:
            ; Reset score
            clr.l   score

            ; Reset lives
            move.w  #3,lives

            ; Clear all home slots
            lea     home_slots,a0
            moveq   #4,d0
.clear_slots:
            clr.w   (a0)+
            dbf     d0,.clear_slots

            ; Reset level
            move.w  #1,level

            ; Reset frog to starting position
            bsr     reset_frog

            ; Set game state
            move.w  #STATE_ALIVE,game_state

            ; Small delay to prevent immediate re-trigger
            move.w  #10,fire_delay

            rts
