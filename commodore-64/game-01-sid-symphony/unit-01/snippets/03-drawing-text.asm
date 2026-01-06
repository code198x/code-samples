draw_top_panel:
            ldx #$00
.loop:
            lda score_text,x
            beq .done           ; Zero byte = end of string
            sta $0400 + 40,x    ; Row 1 of screen
            lda #$01            ; White
            sta $d800 + 40,x    ; Colour for row 1
            inx
            bne .loop
.done:
            rts

score_text:
            !scr "score: 000000          streak: 00"
            !byte 0
