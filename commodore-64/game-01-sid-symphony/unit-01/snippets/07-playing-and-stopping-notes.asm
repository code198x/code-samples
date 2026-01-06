play_note:
            lda #$41            ; Pulse wave ($40) + gate on ($01)
            sta $d404
            rts

stop_note:
            lda #$40            ; Pulse wave, gate off
            sta $d404
            rts
