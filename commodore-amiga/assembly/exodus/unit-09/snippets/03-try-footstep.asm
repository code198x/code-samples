;──────────────────────────────────────────────────────────────
; try_footstep — Play footstep if enough frames have passed
;──────────────────────────────────────────────────────────────
try_footstep:
            move.w  step_timer,d0
            subq.w  #1,d0
            bgt.s   .not_yet

            ; Time to play a step
            bsr     play_step
            move.w  #STEP_INTERVAL,step_timer
            rts

.not_yet:
            move.w  d0,step_timer
            rts
