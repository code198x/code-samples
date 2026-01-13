; ----------------------------------------------------------------------------
; Victory Celebration
; ----------------------------------------------------------------------------
; Flashes border in winner's colour

victory_celebration:
            ; Determine winner's border colour
            ld      a, (p1_count)
            ld      b, a
            ld      a, (p2_count)
            cp      b
            jr      c, .vc_p1           ; p2 < p1
            jr      z, .vc_draw         ; draw - use white
            ld      d, P2_BORDER        ; p2 wins
            jr      .vc_flash
.vc_p1:
            ld      d, P1_BORDER
            jr      .vc_flash
.vc_draw:
            ld      d, 7                ; White for draw

.vc_flash:
            ; Flash border 5 times
            ld      b, 5

.vc_loop:
            push    bc

            ; Winner's colour
            ld      a, d
            out     (KEY_PORT), a

            ; Delay
            ld      bc, 15000
.vc_delay1:
            dec     bc
            ld      a, b
            or      c
            jr      nz, .vc_delay1

            ; Black
            xor     a
            out     (KEY_PORT), a

            ; Delay
            ld      bc, 10000
.vc_delay2:
            dec     bc
            ld      a, b
            or      c
            jr      nz, .vc_delay2

            pop     bc
            djnz    .vc_loop

            ret
