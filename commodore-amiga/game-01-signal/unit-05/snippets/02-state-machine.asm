; Frog State Machine
; Two states: waiting for input, or animating a hop

STATE_IDLE      equ 0           ; Waiting for input
STATE_HOPPING   equ 1           ; Currently animating a hop

DIR_UP          equ 0           ; Direction codes
DIR_DOWN        equ 1
DIR_LEFT        equ 2
DIR_RIGHT       equ 3

update_frog:
            tst.w   frog_state
            beq     .idle           ; STATE_IDLE = 0
            bra     .hopping        ; Must be STATE_HOPPING

.idle:
            ; Check for input, validate move, start hop
            bsr     read_joystick_edge
            tst.w   d0
            beq     .done           ; No input
            ; ... check direction bits, validate move ...
            move.w  #STATE_HOPPING,frog_state
            clr.w   frog_anim_frame
            bra     .done

.hopping:
            ; Animate position, check completion
            addq.w  #1,frog_anim_frame
            ; ... move pixel position ...
            cmp.w   #HOP_FRAMES,frog_anim_frame
            blt.s   .done
            ; Hop complete - update grid, return to idle
            move.w  #STATE_IDLE,frog_state

.done:      rts
