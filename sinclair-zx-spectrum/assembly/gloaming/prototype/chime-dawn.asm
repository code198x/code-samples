chime_dawn:                         ; dusk's bell answered — light returns
            ld      b, $D2          ; C5, where dusk ended, the ground note
            ld      c, $CF
            call    beep
            ld      b, 8
            call    rest
            ld      b, $C6          ; E5, the answer rises the motif
            ld      c, $A4
            call    beep
            ld      b, 4
            call    rest
            ld      b, $FF          ; G5, opens toward morning — the fanfare completes it
            ld      c, $8A
            call    beep
            ld      b, $B1          ; held — B counts to 255, so sound it again
            ld      c, $8A
            jp      beep
