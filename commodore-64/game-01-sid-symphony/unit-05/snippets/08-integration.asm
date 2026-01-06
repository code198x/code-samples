; Note despawned - missed!
            jsr update_crowd_miss   ; Crowd gets unhappier (may end game)
            lda #$00
            sta streak
            ; ...
