update_timer:
            ; Only count down when alive
            cmpi.w  #STATE_ALIVE,game_state
            bne.s   .no_decrement

            ; Decrement timer
            subq.w  #1,timer_value
            bgt.s   .not_zero

            ; Timer expired - death!
            clr.w   timer_value
            move.w  #STATE_DYING,game_state
            move.w  #30,death_timer
            bsr     play_death_sound
            rts

.not_zero:
.no_decrement:
            rts
