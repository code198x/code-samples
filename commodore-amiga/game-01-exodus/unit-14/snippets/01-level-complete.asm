            ; --- Check level complete ---
            move.w  game_state,d0
            cmp.w   #GAME_COMPLETE,d0
            beq.s   .skip_check
            move.w  saved_count,d0
            add.w   lost_count,d0
            cmp.w   #NUM_CREATURES,d0
            blt.s   .skip_check
            ; All creatures accounted for
            move.w  #GAME_COMPLETE,game_state
            bsr     draw_result
.skip_check:
