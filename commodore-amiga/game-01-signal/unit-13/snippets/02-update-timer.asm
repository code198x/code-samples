;------------------------------------------------------------------------------
; UPDATE_TIMER - Decrement timer and check for timeout
;------------------------------------------------------------------------------
update_timer:
            subq.w  #1,timer
            bgt.s   .not_timeout

            ; Timer reached zero - death!
            bsr     trigger_death
            rts

.not_timeout:
            ; Display timer every frame
            bsr     display_timer
            rts
