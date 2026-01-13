; ----------------------------------------------------------------------------
; Flash Border Error
; ----------------------------------------------------------------------------
; Flash border red briefly to indicate error

flash_border_error:
            ; Flash red 3 times
            ld      b, 3

.fbe_loop:
            push    bc

            ; Red border
            ld      a, ERROR_BORDER
            out     (KEY_PORT), a

            ; Short delay (about 3 frames)
            ld      bc, 8000
.fbe_delay1:
            dec     bc
            ld      a, b
            or      c
            jr      nz, .fbe_delay1

            ; Black border (brief off)
            xor     a
            out     (KEY_PORT), a

            ; Short delay
            ld      bc, 4000
.fbe_delay2:
            dec     bc
            ld      a, b
            or      c
            jr      nz, .fbe_delay2

            pop     bc
            djnz    .fbe_loop

            ret
