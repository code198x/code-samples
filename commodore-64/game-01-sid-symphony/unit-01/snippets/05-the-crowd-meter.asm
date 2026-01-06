draw_bottom_panel:
            ldx #$00
.loop:
            lda crowd_text,x
            beq .done
            sta $0400 + (23*40),x
            lda #$05            ; Green
            sta $d800 + (23*40),x
            inx
            bne .loop
.done:
            rts

crowd_text:
            !scr "crowd [          ]"
            !byte 0
