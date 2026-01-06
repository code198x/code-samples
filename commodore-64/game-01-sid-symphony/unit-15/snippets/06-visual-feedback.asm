PAUSE_ROW   = 11
PAUSE_COL   = 17

draw_paused_text:
            ldx #0
dpt_loop:
            lda paused_text,x
            beq dpt_done
            sta SCREEN + PAUSE_ROW * 40 + PAUSE_COL,x
            lda #COL_YELLOW
            sta COLOUR + PAUSE_ROW * 40 + PAUSE_COL,x
            inx
            jmp dpt_loop
dpt_done:
            rts

erase_paused_text:
            ldx #0
ept_loop:
            lda #32                 ; Space character
            sta SCREEN + PAUSE_ROW * 40 + PAUSE_COL,x
            lda #COL_BLACK
            sta COLOUR + PAUSE_ROW * 40 + PAUSE_COL,x
            inx
            cpx #6                  ; "PAUSED" is 6 characters
            bne ept_loop
            rts

paused_text:
            !scr "paused"
            !byte 0
