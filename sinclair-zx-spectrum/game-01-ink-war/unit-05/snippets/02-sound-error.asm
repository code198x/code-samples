; ----------------------------------------------------------------------------
; Sound - Error
; ----------------------------------------------------------------------------
; Harsh buzz for invalid move

sound_error:
            ld      b, 30               ; Duration

.se_loop:
            push    bc

            ; Low frequency buzz (longer delay = lower pitch)
            ld      a, $10
            out     (KEY_PORT), a
            ld      c, 80               ; Longer delay for low pitch
.se_delay1:
            dec     c
            jr      nz, .se_delay1

            xor     a
            out     (KEY_PORT), a
            ld      c, 80
.se_delay2:
            dec     c
            jr      nz, .se_delay2

            pop     bc
            djnz    .se_loop

            ret
