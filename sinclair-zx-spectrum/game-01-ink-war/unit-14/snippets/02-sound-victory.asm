; ----------------------------------------------------------------------------
; Sound - Victory
; ----------------------------------------------------------------------------
; Triumphant ascending fanfare - three rising notes

sound_victory:
            ; Play three ascending notes
            ld      hl, 60              ; Starting pitch (low)
            ld      b, 3                ; Three notes

.sv_note:
            push    bc
            push    hl

            ; Play note
            ld      b, 25               ; Note duration
.sv_tone:
            push    bc
            ld      a, $10
            out     (KEY_PORT), a
            ld      b, l
.sv_d1:     djnz    .sv_d1
            xor     a
            out     (KEY_PORT), a
            ld      b, l
.sv_d2:     djnz    .sv_d2
            pop     bc
            djnz    .sv_tone

            pop     hl
            pop     bc

            ; Decrease delay (higher pitch) for next note
            ld      a, l
            sub     15
            ld      l, a

            ; Brief pause between notes
            push    bc
            ld      bc, 2000
.sv_pause:  dec     bc
            ld      a, b
            or      c
            jr      nz, .sv_pause
            pop     bc

            djnz    .sv_note
            ret
