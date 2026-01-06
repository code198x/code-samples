draw_tracks:
            ; Track 1 (row 8) - dimmed grey
            ldx #$00
.t1_loop:
            cpx #$04            ; First 4 columns = hit zone
            bcs .t1_lane
            lda #$a0            ; Solid block
            jmp .t1_store
.t1_lane:
            lda #$2d            ; Dash character
.t1_store:
            sta $0400 + (8*40),x
            lda #$0b            ; Grey
            sta $d800 + (8*40),x
            inx
            cpx #40
            bne .t1_loop

            ; Track 2 (row 12) - active cyan
            ldx #$00
.t2_loop:
            cpx #$04
            bcs .t2_lane
            lda #$a0
            jmp .t2_store
.t2_lane:
            lda #$2d
.t2_store:
            sta $0400 + (12*40),x
            lda #$03            ; Cyan
            sta $d800 + (12*40),x
            inx
            cpx #40
            bne .t2_loop

            ; Track 3 (row 16) - dimmed grey
            ldx #$00
.t3_loop:
            cpx #$04
            bcs .t3_lane
            lda #$a0
            jmp .t3_store
.t3_lane:
            lda #$2d
.t3_store:
            sta $0400 + (16*40),x
            lda #$0b            ; Grey
            sta $d800 + (16*40),x
            inx
            cpx #40
            bne .t3_loop

            rts
