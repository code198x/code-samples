; Death State and Flash Effect
; Screen flashes red by modifying Copper colour register

trigger_death:
            move.w  #STATE_DYING,frog_state
            move.w  #DEATH_FRAMES,death_timer
            move.w  #FLASH_COLOUR,flash_colour
            rts

; In update_frog, handle dying state:
.dying:
            ; Count down death timer
            subq.w  #1,death_timer
            bgt.s   .still_dying

            ; Death complete - respawn
            bsr     respawn_frog
            bra     .done

.still_dying:
            ; Flash effect: alternate colour every 4 frames
            move.w  death_timer,d0
            and.w   #4,d0               ; Bit 2 toggles every 4 frames
            beq.s   .flash_off
            move.w  #FLASH_COLOUR,flash_colour
            bra     .done
.flash_off:
            move.w  #COLOUR_BLACK,flash_colour
            bra     .done

; At end of update_frog, copy flash colour to Copper list:
.done:
            move.w  flash_colour,flash_copper
            rts
