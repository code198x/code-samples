title_dusk:
            ld      b, $84          ; A4, the toll — cold ground
            ld      c, $F7
            call    beep
            ld      b, 10
            call    rest
            ld      b, $84          ; A4
            ld      c, $F7
            call    beep
            ld      b, 13
            call    rest
            ld      b, $92          ; E5, the dusk motif, a lamp far off
            ld      c, $A4
            call    beep
            ld      b, 4
            call    rest
            ld      b, $9D          ; C5
            ld      c, $CF
            call    beep
            ld      b, 13
            call    rest
            ld      b, $84          ; A4, the toll returns
            ld      c, $F7
            call    beep
            ld      b, 10
            call    rest
            ld      b, $5E          ; C5, a small warmth kindles
            ld      c, $CF
            call    beep
            ld      b, 3
            call    rest
            ld      b, $77          ; E5
            ld      c, $A4
            call    beep
            ld      b, 4
            call    rest
            ld      b, $EC          ; D5, left hanging — leans back into the dark
            ld      c, $B8
            call    beep
            ld      b, 16
            jp      rest
