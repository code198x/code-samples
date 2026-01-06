draw_crowd:
            jsr get_crowd_colour
            sta crowd_colour        ; Save for drawing

            ldx #$00                ; Position counter
            ldy crowd_meter         ; Blocks to draw
-           cpx #CROWD_MAX
            bcs +                   ; Done when X >= MAX

            cpy #$00
            beq ++
            lda #$a0                ; Solid block
            dey                     ; One less to draw
            jmp +++
++          lda #$20                ; Space (empty slot)
+++         sta SCREEN + (ROW_CROWD * 40) + 8,x
            lda crowd_colour
            sta COLOUR + (ROW_CROWD * 40) + 8,x
            inx
            jmp -
+           rts
