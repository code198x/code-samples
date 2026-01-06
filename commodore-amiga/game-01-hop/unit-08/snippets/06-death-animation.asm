; Update death animation
; Call once per frame
update_death:
            ; Check if dying
            cmp.w   #STATE_DYING,frog_state
            bne.s   .check_dead

            ; Count down timer
            subq.w  #1,death_timer
            bne.s   .flash

            ; Timer hit zero - transition to dead
            move.w  #STATE_DEAD,frog_state
            bra.s   .respawn

.flash:
            ; Flash sprite: hide on odd frames
            move.w  death_timer,d0
            and.w   #1,d0               ; Check odd/even
            beq.s   .show

            ; Hide sprite by moving off-screen
            move.w  #0,spr0_ctl         ; Clear control word
            bra.s   .done

.show:
            ; Show sprite (will be redrawn in main loop)
            bra.s   .done

.check_dead:
            cmp.w   #STATE_DEAD,frog_state
            bne.s   .done

.respawn:
            ; Reset frog to start position
            move.w  #FROG_START_X,frog_x
            move.w  #FROG_START_Y,frog_y
            move.w  #STATE_ALIVE,frog_state
            clr.w   on_log

.done:
            rts
