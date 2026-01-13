; ----------------------------------------------------------------------------
; Sound - Startup
; ----------------------------------------------------------------------------
; Quick ascending jingle when game loads

sound_startup:
            ; Three quick ascending notes
            ld      hl, 50              ; Starting pitch
            ld      b, 3                ; Three notes

.sst_note:
            push    bc
            push    hl

            ; Play note
            ld      b, 12               ; Short duration
.sst_tone:
            push    bc
            ld      a, $10
            out     (KEY_PORT), a
            ld      b, l
.sst_d1:    djnz    .sst_d1
            xor     a
            out     (KEY_PORT), a
            ld      b, l
.sst_d2:    djnz    .sst_d2
            pop     bc
            djnz    .sst_tone

            pop     hl
            pop     bc

            ; Decrease delay (higher pitch) for next note
            ld      a, l
            sub     12
            ld      l, a

            ; Brief pause between notes
            push    bc
            ld      bc, 1000
.sst_pause: dec     bc
            ld      a, b
            or      c
            jr      nz, .sst_pause
            pop     bc

            djnz    .sst_note
            ret
