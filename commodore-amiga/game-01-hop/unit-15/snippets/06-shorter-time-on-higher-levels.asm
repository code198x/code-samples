get_level_timer:
; Returns d0 = timer start value for current level
            move.w  #TIMER_START,d0
            move.w  level,d1
            subq.w  #1,d1           ; Level 1 = no reduction
            mulu    #50,d1          ; 1 second less per level
            sub.w   d1,d0

            ; Minimum of 15 seconds
            cmpi.w  #750,d0
            bge.s   .not_too_low
            move.w  #750,d0
.not_too_low:
            rts
