; ----------------------------------------------------------------------------
; Display Combo - Show combo count and multiplier with colour feedback
; ----------------------------------------------------------------------------

COMBO_ROW = 2                   ; Second row of screen

display_combo:
            ; Draw "COMBO:" label
            ldx #0
draw_combo_label:
            lda combo_label,x
            beq draw_combo_value
            sta SCREEN + (COMBO_ROW * 40) + 12,x
            lda #11             ; Grey for label
            sta COLRAM + (COMBO_ROW * 40) + 12,x
            inx
            jmp draw_combo_label

draw_combo_value:
            ; Display 3-digit combo value
            lda combo

            ; Hundreds digit
            ldx #0
combo_div_100:
            cmp #100
            bcc combo_done_100
            sec
            sbc #100
            inx
            jmp combo_div_100
combo_done_100:
            pha
            txa
            ora #$30            ; Convert to screen code
            sta SCREEN + (COMBO_ROW * 40) + 18
            pla

            ; Tens digit
            ldx #0
combo_div_10:
            cmp #10
            bcc combo_done_10
            sec
            sbc #10
            inx
            jmp combo_div_10
combo_done_10:
            pha
            txa
            ora #$30
            sta SCREEN + (COMBO_ROW * 40) + 19
            pla

            ; Ones digit
            ora #$30
            sta SCREEN + (COMBO_ROW * 40) + 20

            ; Colour based on multiplier tier
            jsr get_multiplier
            cmp #4
            beq combo_col_4x
            cmp #3
            beq combo_col_3x
            cmp #2
            beq combo_col_2x

            lda #11             ; 1x = grey (no bonus)
            jmp set_combo_col

combo_col_2x:
            lda #7              ; 2x = yellow
            jmp set_combo_col

combo_col_3x:
            lda #5              ; 3x = green
            jmp set_combo_col

combo_col_4x:
            lda #1              ; 4x = white (maximum!)

set_combo_col:
            sta COLRAM + (COMBO_ROW * 40) + 18
            sta COLRAM + (COMBO_ROW * 40) + 19
            sta COLRAM + (COMBO_ROW * 40) + 20

            ; Display multiplier (e.g., "2x")
            jsr get_multiplier
            ora #$30
            sta SCREEN + (COMBO_ROW * 40) + 22
            lda #$18            ; 'x' character
            sta SCREEN + (COMBO_ROW * 40) + 23

            rts

combo_label:
            !scr "combo:"
            !byte 0
