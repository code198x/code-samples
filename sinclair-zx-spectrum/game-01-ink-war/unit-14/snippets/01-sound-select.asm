; ----------------------------------------------------------------------------
; Sound - Menu Select
; ----------------------------------------------------------------------------
; Quick high beep for menu selection

sound_select:
            ld      b, 15               ; Short duration

.ss_loop:
            push    bc

            ld      a, $10
            out     (KEY_PORT), a
            ld      c, 20               ; High pitch (short delay)
.ss_delay1:
            dec     c
            jr      nz, .ss_delay1

            xor     a
            out     (KEY_PORT), a
            ld      c, 20
.ss_delay2:
            dec     c
            jr      nz, .ss_delay2

            pop     bc
            djnz    .ss_loop

            ret
