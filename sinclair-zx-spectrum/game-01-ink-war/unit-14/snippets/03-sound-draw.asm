; ----------------------------------------------------------------------------
; Sound - Draw
; ----------------------------------------------------------------------------
; Neutral two-tone sound for draw - same pitch repeated

sound_draw:
            ; First tone (mid pitch)
            ld      b, 20
.sd_tone1:
            push    bc
            ld      a, $10
            out     (KEY_PORT), a
            ld      c, 40
.sd_d1:     dec     c
            jr      nz, .sd_d1
            xor     a
            out     (KEY_PORT), a
            ld      c, 40
.sd_d2:     dec     c
            jr      nz, .sd_d2
            pop     bc
            djnz    .sd_tone1

            ; Brief pause
            ld      bc, 1500
.sd_pause:  dec     bc
            ld      a, b
            or      c
            jr      nz, .sd_pause

            ; Second tone (same pitch - neutral)
            ld      b, 20
.sd_tone2:
            ; ... same as first tone ...
            djnz    .sd_tone2

            ret
